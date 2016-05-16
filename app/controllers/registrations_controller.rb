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

end
