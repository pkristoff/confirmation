# frozen_string_literal: true

module Dev
  # Used when candidate is signed in (as opposed to admin, who has authority to do the same thing).
  class CandidatesController < CommonCandidatesController
    # CANDIDATE ONLY

    helper DeviseHelper

    # make the following methods available in the view.
    helpers = %w[resource scope_name resource_name signed_in_resource
                 resource_class resource_params devise_mapping]
    helper_method(*helpers)

    # used for testing only
    attr_accessor :candidates
    # used for testing only
    attr_accessor :candidate

    # A candidate should be signed in.
    before_action :authenticate_candidate!

    # Should never be called
    #
    def edit
      @candidate = Candidate.find(params[:id])
    end

    # Should never be called
    #
    def event
      @candidate = Candidate.find(params[:id])
    end

    # Should never be called
    #
    def index
      redirect_back fallback_location: ref_url, alert: 'Please login as admin to see list of candidates.' unless admin_signed_in?
    end

    # returns false
    #
    def admin?
      false
    end

    # Should never be called
    #
    def show
      @candidate = Candidate.find(params[:id])
      redirect_back fallback_location: ref_url, alert: I18n.t('messages.accessed_denied') unless @candidate == current_candidate
    end

    private

    def ref_url
      referrer_url = nil
      begin
        # get a URI object for referring url
        referrer_url = URI.parse(request.referer)
      rescue StandardError
        referrer_url = URI.parse(some_default_url)
        # need to have a default in case referrer is not given
      end
      referrer_url
    end
  end
end
