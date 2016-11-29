include ApplicationHelper

class ApplicationController < ActionController::Base
  before_filter :configure_permitted_parameters, if: :devise_controller?

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def event_class(candidate_event)

    if candidate_event.due_date.nil?
      'event-unitialized'
    elsif candidate_event.late?
      'event-late'
    elsif candidate_event.awaiting_candidate?
      'event-awaiting-candidate'
    elsif candidate_event.awaiting_admin?
      'event-awaiting-verification'
    elsif candidate_event.completed?
      'event-completed'
    else
      ''
    end
  end

  protected

  def configure_permitted_parameters
    if devise_mapping.name == :admin
      devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit(:name, :password, :password_confirmation, :remember_me) }
      devise_parameter_sanitizer.permit(:sign_in) { |u| u.permit(:name, :password, :remember_me) }
      devise_parameter_sanitizer.permit(:account_update) { |u| u.permit(:name, :password, :password_confirmation, :current_password) }
    else
      # admin is editing a candidate's account info
      devise_parameter_sanitizer.permit(:sign_in) do |candidate_parms|
        candidate_parms.permit(:account_name, :parent_email_1)
      end
      devise_parameter_sanitizer.permit(:sign_up) do |candidate_parms|
        candidate_parms.permit(*candidate_permitted_params)
      end
      devise_parameter_sanitizer.permit(:account_update) do |candidate_parms|
        candidate_parms.permit(*(candidate_signed_in? ? [:current_password] : []), *candidate_permitted_params)
      end
    end
  end

  def candidate_params
    params.require(:candidate).permit(candidate_permitted_params)
  end

  def certificate_file_params
    params.require(:candidate).permit(baptismal_certificate_attributes: [:certificate_filename, :certificate_content_type, :certificate_file_contents])
  end

  def sponsor_elegibility_file_params
    params.require(:candidate).permit(sponsor_covenant_attributes: [:sponsor_elegibility_filename, :sponsor_elegibility_content_type, :sponsor_elegibility_file_contents])
  end

  def pick_confirmation_name_file_params
    params.require(:candidate).permit(pick_confirmation_name_attributes: [:pick_confirmation_name_filename, :pick_confirmation_name_content_type, :pick_confirmation_name_file_contents])
  end

  def candidate_permitted_params
    Candidate.get_permitted_params
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) ||
        if resource.is_a?(Candidate)
          if candidate_signed_in?
            event_candidate_registration_url(resource.id)
          else
            candidate_url(resource.id)
          end
        else
          if admin_signed_in?
            admin_path(resource.id)
          else
            super
          end
        end
  end

  def set_candidates(selected_candidate_ids = [])
    sc = sort_column(params[:sort])
    sc_split = sc.split('.')
    @selected_candidate_ids = selected_candidate_ids
    if sc_split.size === 2
      if sc_split[0] === 'candidate_sheet'
        @candidates = Candidate.joins(:candidate_sheet).order("candidate_sheets.#{sc_split[1]} #{sort_direction(params[:direction])}").all
      else
        flash[:alert] = "Unknown sort_column: #{sc}"
      end
    else
      if sc_split[0] === 'completed_date'
        @candidates = Candidate.joins(candidate_events: :confirmation_event)
                          .where(confirmation_events: {name: @confirmation_event.name})
                          .order("candidate_events.completed_date #{sort_direction(params[:direction])}")
      else
        @candidates = Candidate.order("#{sc} #{sort_direction(params[:direction])}").all
      end
    end
  end

end
