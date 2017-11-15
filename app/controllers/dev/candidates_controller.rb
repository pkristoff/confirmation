module Dev
  # Used when candidate is signed in (as opposed to admin, who has authority to do the same thing).
  class CandidatesController < CommonCandidatesController

    # CANDIDATE ONLY

    helper DeviseHelper

    # make the following methods available in the view.
    helpers = %w(resource scope_name resource_name signed_in_resource
               resource_class resource_params devise_mapping)
    helper_method(*helpers)

    # used for testing only
    attr_accessor :candidates
    # used for testing only
    attr_accessor :candidate
    # A candidate should be signed in.
    before_action :authenticate_candidate!

    # Should never be called
    def edit
      @candidate = Candidate.find(params[:id])
    end

    # Should never be called
    def event
      @candidate = Candidate.find(params[:id])
    end

    # Should never be called
    def index
      unless admin_signed_in?
        redirect_to :back, alert: 'Please login as admin to see list of candidates.'
      end
    end

    def is_admin?
      false
    end

    # Should never be called
    def show
      @candidate = Candidate.find(params[:id])
      unless @candidate == current_candidate
        redirect_to :back, alert: I18n.t('messages.accessed_denied')
      end
    end

  end
end