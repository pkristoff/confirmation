# frozen_string_literal: true

#
# Handles Admin tasks
#
class VisitorsController < ApplicationController
  # redirect to appropriate routing depending who is logged in.
  #
  def index
    if candidate_signed_in?
      redirect_to dev_candidate_path(current_candidate.id)
    elsif admin_signed_in?
      redirect_to admin_path(current_admin.id)
    end
    @candidate = nil
  end

  # If id == -1 then create a new candidate otherwise find one.
  #
  # === Attributes
  #
  # * <tt>:id</tt> Candidate id
  # * <tt>:erros</tt>
  #
  def candidate_confirmation
    @candidate = params[:id].to_i.equal?('-1'.to_i) ? Candidate.create : Candidate.find(params[:id])
    @errors = params[:errors]
    sign_out current_admin if admin_signed_in?
  end

  # Devise method
  #
  # === Returns:
  #
  # * <tt>Candidate</tt>
  #
  def resource
    @candidate
  end
end
