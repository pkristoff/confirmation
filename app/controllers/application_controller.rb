class ApplicationController < ActionController::Base
  before_filter :configure_permitted_parameters, if: :devise_controller?

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:name, :email, :password, :password_confirmation, :remember_me) }
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:name, :email, :password, :remember_me) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:name, :email, :password, :password_confirmation, :current_password) }
  end

  def puts_controller
    puts "#{self.class.to_s} before"
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
