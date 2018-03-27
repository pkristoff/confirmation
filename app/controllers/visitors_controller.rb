# frozen_string_literal: true

#
# Handles Admin tasks
#
class VisitorsController < ApplicationController
  def index
    if candidate_signed_in?
      redirect_to dev_candidate_path(current_candidate.id)
    elsif admin_signed_in?
      redirect_to admin_path(current_admin.id)
    end
    @candidate = nil
  end

  def candidate_confirmation
    @candidate = params[:id].to_i.equal?('-1'.to_i) ? Candidate.create : Candidate.find(params[:id])
    @errors = params[:errors]
    sign_out current_admin if admin_signed_in?
  end

  def resource
    @candidate
  end
end
