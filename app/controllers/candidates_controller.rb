class CandidatesController < CommonCandidatesController
  helper_method :sort_column, :sort_direction

  # ADMIN ONLY

  helper DeviseHelper

  helpers = %w(resource scope_name resource_name signed_in_resource
               resource_class resource_params devise_mapping)
  helper_method(*helpers)

  attr_accessor :candidate_info # for testing
  attr_accessor :candidate # for testing

  before_action :authenticate_admin!

  def edit
    @candidate = Candidate.find(params[:id])
    @resource = @candidate
  end

  def event
    @resource = Candidate.find(params[:id])
  end

  def index
    set_candidates
  end

  def is_admin?
    true
  end

  def new
    @resource = AppFactory.create_candidate
  end

  def show
    @candidate = Candidate.find(params[:id])
  end

  def update
    if params[:candidate][:password].blank?
      params[:candidate].delete(:password)
      params[:candidate].delete(:password_confirmation)
    end
    @resource = Candidate.find(params[:id])
    if @resource.update_attributes(candidate_params)
      flash[:notice] = I18n.t('messages.candidate_updated', name: @resource.account_name)
      render :event, id: @resource.id
    else
      render edit
    end
  end

  def candidate_sheet_verify
    @candidate = Candidate.find(params[:id])
  end

  def candidate_sheet_verify_update
    @candidate = Candidate.find(params[:id])

    render_called = event_with_picture_update_private(CandidateSheet, true)

    render :candidate_sheet_verify unless render_called

  end

  def christian_ministry_verify
    @candidate = Candidate.find(params[:id])
  end

  def christian_ministry_verify_update
    @candidate = Candidate.find(params[:id])

    render_called = event_with_picture_update_private(ChristianMinistry, true)

    render :christian_ministry_verify unless render_called

  end

  def pick_confirmation_name_verify
    @candidate = Candidate.find(params[:id])
  end

  def pick_confirmation_name_verify_update
    @candidate = Candidate.find(params[:id])

    render_called = event_with_picture_update_private(PickConfirmationName, true)

    render :pick_confirmation_name_verify unless render_called
  end

  def sponsor_agreement_verify
    @is_verify = true
    @candidate = Candidate.find(params[:id])
  end

  def sponsor_agreement_verify_update
    @candidate = Candidate.find(params[:id])
    render_called = agreement_update_private(I18n.t('events.sponsor_agreement'), 'sponsor_agreement', I18n.t('label.sponsor_agreement.sponsor_agreement'), true)
    @is_verify = true
    render :sponsor_agreement_verify unless render_called
  end

  protected

  def resource_class
    devise_mapping.to
  end

  # Since going around devise mechanisms - add some helpers back in.
  def resource
    @resource
  end

  # Since going around devise mechanisms - add some helpers back in.
  def resource_name
    devise_mapping.name
  end

  # Since going around devise mechanisms - add some helpers back in.
  def devise_mapping
    Devise.mappings[:candidate]
  end

end
