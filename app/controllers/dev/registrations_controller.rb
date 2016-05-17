module Dev
  class RegistrationsController < Devise::RegistrationsController

    before_action :authenticate_candidate!
    skip_before_filter :require_no_authentication, only: [:new, :create, :destroy]
    # prepend_before_filter :require_no_authentication, :only => [ :new, :create ]

    def create
      redirect_to :back, :alert => 'Please login as admin to create another admin.'
    end

    def destroy
      redirect_to :back, :alert => 'Please login as admin to remove a candidate.'
    end

    def new
      redirect_to :back, :alert => 'Please login as admin to create another candidate.'
    end

    def after_update_path_for(resource_or_scope)
      dev_candidate_path(current_candidate.id)
    end

    def devise_mapping
      Devise.mappings[:candidate]
    end

    def configure_permitted_parameters
      if (devise_mapping.name == :admin)
        super
      else
        devise_parameter_sanitizer.for(:sign_in) do |candidate_parms|
          candidate_parms.permit(:candidate_id, :parent_email_1)
        end
        devise_parameter_sanitizer.for(:sign_up) do |candidate_parms|
          candidate_parms.permit(:candidate_id, :first_name, :last_name, :candidate_email, :parent_email_1,
                                 :parent_email_2, :grade, :attending, :password, :password_confirmation)
        end
        devise_parameter_sanitizer.for(:account_update) do |candidate_parms|
          candidate_parms.permit(:candidate_id, :first_name, :last_name, :candidate_email, :parent_email_1,
                                 :parent_email_2, :grade, :attending, :password, :password_confirmation,
                                 :current_password)
        end
      end
    end

  end
end
