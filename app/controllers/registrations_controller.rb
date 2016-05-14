class RegistrationsController < Devise::RegistrationsController

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

end
