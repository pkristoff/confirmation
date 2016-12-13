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

  # args
  #   - selected_candidate_ids:  Array of initially selected candidates
  #   - confirmation_event:  Confirmation event used for mass update of candidate event for candidates.
  def set_candidates(sort_column, args = {})
    args = {confirmation_event: nil, selected_candidate_ids: []}.merge(args)
    @confirmation_event = args[:confirmation_event]
    @selected_candidate_ids = args[:selected_candidate_ids]
    @candidates = Candidate.all
  end

end
