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

    def candidate_sheet
      @candidate = Candidate.find(params[:id])
    end

    def candidate_sheet_update
      candidate = Candidate.find(params[:id])
      candidate_event = candidate.candidate_events.find { |ce| ce.name == I18n.t('events.fill_out_candidate_sheet') }
      candidate_event.completed_date = Date.today

      if candidate.update_attributes(candidate_params)
        redirect_to event_candidate_registration_path(params[:id]), notice: 'Updated'
      else
        redirect_to :back, alert: 'Saving failed.'
      end
    end

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
      true
    end

    def show
      @candidate = Candidate.find(params[:id])
      # @resource = @candidate
      unless @candidate == current_candidate
        redirect_to :back, alert: I18n.t('messages.accessed_denied')
      end
    end

  end
end