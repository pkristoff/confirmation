class RegistrationsController < Devise::RegistrationsController

  before_action :authenticate_admin!
  skip_before_filter :require_no_authentication, only: [:new, :create, :destroy]

  def create
    unless admin_signed_in?
      return redirect_to :back, :alert => "Please login as admin to create another admin."
    end
    super
  end

  def destroy
    unless admin_signed_in?
      return redirect_to :back, :alert => "Please login as admin to remove a candidate."
    end
    super
  end

  def new
    unless admin_signed_in?
      return redirect_to :back, :alert => "Please login as admin to create another admin."
    end
    super
  end

  def after_update_path_for(resource_or_scope)
    current_candidate
  end

  def update_resource(resource, params)
    params.delete(:current_password)
    resource.update_without_password(params)
  end

  def devise_mapping
    mapping = super
    mapping = Devise.mappings[:candidate] if mapping.nil?
    mapping
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
                               :parent_email_2, :grade, :attending, :password, :password_confirmation)
      end
    end
  end

end
