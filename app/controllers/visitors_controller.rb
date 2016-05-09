class VisitorsController < ApplicationController
  def index
    if candidate_signed_in?
      redirect_to "/candidates#index"
    elsif admin_signed_in?
      redirect_to "/admins#index"
    end
  end
end
