class VisitorsController < ApplicationController
  def index
    if user_signed_in?
      redirect_to "/users#index"
    elsif admin_signed_in?
      redirect_to "/admins#index"
    end
  end
end
