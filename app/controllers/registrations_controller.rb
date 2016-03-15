class RegistrationsController < Devise::RegistrationsController

  skip_before_filter :require_no_authentication, only: [:new, :create]

  def create
    super
  end

  def new
    super
  end


end
