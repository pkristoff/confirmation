class CandidatesController < ApplicationController

  attr_accessor :candidates # for testing
  attr_accessor :candidate # for testing

  before_action :check_candidate_or_admin_logged_in!

  def index
    @candidates = Candidate.all
  end

  def show
    @candidate = Candidate.find(params[:id])
    unless admin_signed_in? or @candidate == current_candidate
      redirect_to :back, :alert => "Access denied."
    end
  end

  private
  def check_candidate_or_admin_logged_in!
    authenticate_candidate! unless admin_signed_in?
  end

end
