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
      devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit(:name, :email, :password, :password_confirmation, :remember_me) }
      devise_parameter_sanitizer.permit(:sign_in) { |u| u.permit(:name, :email, :password, :remember_me) }
      devise_parameter_sanitizer.permit(:account_update) { |u| u.permit(:name, :email, :password, :password_confirmation, :current_password) }
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

  def candidate_permitted_params
    [:account_name, :first_name, :last_name, :confirmation_name, :candidate_email, :parent_email_1,
     :parent_email_2, :grade, :attending, :password, :password_confirmation,
     address_attributes: [:street_1, :street_2, :city, :state, :zip_code],
     candidate_events_attributes: [:id, :completed_date, :verified]
    ]
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) ||
        if resource.is_a?(Candidate)
          if candidate_signed_in?
            dev_candidate_url(resource.id)
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

end
