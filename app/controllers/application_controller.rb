class ApplicationController < ActionController::Base
  before_filter :configure_permitted_parameters, if: :devise_controller?

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  protected

  def configure_permitted_parameters
    if (devise_mapping.name == :admin)
      devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit(:name, :email, :password, :password_confirmation, :remember_me) }
      devise_parameter_sanitizer.permit(:sign_in) { |u| u.permit(:name, :email, :password, :remember_me) }
      devise_parameter_sanitizer.permit(:account_update) { |u| u.permit(:name, :email, :password, :password_confirmation, :current_password) }
    else
      # admin is editing a candidate's account info
      devise_parameter_sanitizer.permit(:sign_in) do |candidate_parms|
        candidate_parms.permit(:candidate_id, :parent_email_1)
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
    [:candidate_id, :first_name, :last_name, :candidate_email, :parent_email_1,
     :parent_email_2, :grade, :attending, :password, :password_confirmation,
     address_attributes: [:street_1, :street_2, :city, :state, :zip_code]]
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
          super
        end
  end

end
