module Dev
  class CandidatesController < ApplicationController

    # CANDIDATE ONLY

    helper DeviseHelper

    helpers = %w(resource scope_name resource_name signed_in_resource
               resource_class resource_params devise_mapping)
    helper_method(*helpers)

    attr_accessor :candidates # for testing
    attr_accessor :candidate # for testing
    before_action :authenticate_candidate!

    def edit
      @candidate = Candidate.find(params[:id])
    end

    def event
      @candidate = Candidate.find(params[:id])
    end

    def index
      unless admin_signed_in?
        redirect_to :back, alert: 'Please login as admin to see list of candidates.'
      end
    end

    def show
      @candidate = Candidate.find(params[:id])
      # @resource = @candidate
      unless @candidate == current_candidate
        redirect_to :back, alert: 'Access denied.'
      end

    end

    def sign_agreement
      @candidate = Candidate.find(params[:id])
    end

    def sign_agreement_update
      candidate = Candidate.find(params[:id])
      if candidate.update_attributes(candidate_params)
        redirect_to event_candidate_registration_path(params[:id]), notice: 'Updated'
      else
        redirect_to :back, alert: 'Saving failed.'
      end
    end

  end
end