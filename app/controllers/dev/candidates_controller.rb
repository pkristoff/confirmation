module Dev
  class CandidatesController < CommonCandidatesController

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

    def is_admin?
      false
    end

    def show
      @candidate = Candidate.find(params[:id])
      unless @candidate == current_candidate
        redirect_to :back, alert: I18n.t('messages.accessed_denied')
      end
    end

  end
end