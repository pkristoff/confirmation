class VisitorsController < ApplicationController
  def index
    if candidate_signed_in?
      redirect_to dev_candidate_path(current_candidate.id)
    elsif admin_signed_in?
      redirect_to admin_path(current_admin.id)
    end
  end
end
