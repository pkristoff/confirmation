# frozen_string_literal: true

#
# Handles Candidate tasks
#
class CandidatesController < CommonCandidatesController
  helper_method :sort_column, :sort_direction

  # ADMIN ONLY

  helper DeviseHelper

  helpers = %w[resource scope_name resource_name signed_in_resource
               resource_class resource_params devise_mapping]
  helper_method(*helpers)

  attr_accessor :candidate_info # for testing
  attr_accessor :candidate # for testing
  # Since going around devise mechanisms - add some helpers back in.
  attr_reader :resource

  before_action :authenticate_admin!

  # edit candidate
  #
  # === Attributes:
  #
  # * <tt>:id</tt> Candidate id
  #
  def edit
    @candidate = Candidate.find(params[:id])
    @resource = @candidate
  end

  # edit event
  #
  # === Attributes:
  #
  # * <tt>:id</tt> Candidate id
  #
  def event
    @resource = Candidate.find(params[:id])
  end

  # show candidates
  #
  def index
    candidates_info
  end

  # show candidate
  #
  # === Returns:
  #
  # * <code>Boolean</code>
  #
  def admin?
    true
  end

  # create new Candidate
  #
  def new
    @resource = AppFactory.create_candidate
  end

  # show candidate
  #
  # === Attributes:
  #
  # * <tt>:id</tt> Candidate id
  #
  def show
    @candidate = Candidate.find(params[:id])
  end

  # update candidate - only update password if filled in
  #
  # === Attributes:
  #
  # * <tt>:id</tt> Candidate id
  # * <tt>:candidate</tt>
  # ** <code>:password</code>
  # ** <code>:password_confirmation</code>
  #
  def update
    if params[:candidate][:password].blank?
      params[:candidate].delete(:password)
      params[:candidate].delete(:password_confirmation)
    end
    @resource = Candidate.find(params[:id])
    if @resource.update(candidate_params)
      flash[:notice] = I18n.t('messages.candidate_updated', name: @resource.account_name)
      render :event, id: @resource.id
    else
      render edit
    end
  end

  # edit candidate_sheet verify
  #
  # === Attributes:
  #
  # * <tt>:id</tt> Candidate id
  #
  def candidate_sheet_verify
    @candidate = Candidate.find(params[:id])
  end

  # update candidate_sheet verify
  #
  # === Attributes:
  #
  # * <tt>:commit</tt> legal values
  # ** <code>views.common.un_verify</code>
  # * <tt>:id</tt> Candidate id
  #
  def candidate_sheet_verify_update
    is_unverify = params[:commit] == I18n.t('views.common.un_verify')

    candidate_id = params[:id]
    event_name = I18n.t('events.candidate_information_sheet')
    @candidate = Candidate.find(candidate_id)
    candidate_event = @candidate.get_candidate_event(event_name)

    return admin_unverified_private(@candidate, candidate_event) if is_unverify

    @candidate = Candidate.find(params[:id])

    render_called = event_with_picture_update_private(CandidateSheet, true)

    render :candidate_sheet_verify unless render_called
  end

  # edit christian_ministry verify
  #
  # === Attributes:
  #
  # * <tt>:id</tt> Candidate id
  #
  def christian_ministry_verify
    @candidate = Candidate.find(params[:id])
  end

  # update christian_ministry verify
  #
  # === Attributes:
  #
  # * <tt>:commit</tt> legal values
  # ** <code>views.common.un_verify</code>
  # * <tt>:id</tt> Candidate id
  #
  def christian_ministry_verify_update
    is_unverify = params[:commit] == I18n.t('views.common.un_verify')

    candidate_id = params[:id]
    event_name = I18n.t('events.christian_ministry')
    @candidate = Candidate.find(candidate_id)
    candidate_event = @candidate.get_candidate_event(event_name)

    return admin_unverified_private(@candidate, candidate_event) if is_unverify

    @candidate = Candidate.find(params[:id])

    render_called = event_with_picture_update_private(ChristianMinistry, true)

    render :christian_ministry_verify unless render_called
  end

  # edit pick_confirmation_name verify
  #
  # === Attributes:
  #
  # * <tt>:id</tt> Candidate id
  #
  def pick_confirmation_name_verify
    @candidate = Candidate.find(params[:id])
  end

  # update pick_confirmation_name verify
  #
  # === Attributes:
  #
  # * <tt>:commit</tt> legal values
  # ** <code>views.common.un_verify</code>
  # * <tt>:id</tt> Candidate id
  #
  def pick_confirmation_name_verify_update
    is_unverify = params[:commit] == I18n.t('views.common.un_verify')

    candidate_id = params[:id]
    event_name = I18n.t('events.confirmation_name')
    @candidate = Candidate.find(candidate_id)
    candidate_event = @candidate.get_candidate_event(event_name)

    return admin_unverified_private(@candidate, candidate_event) if is_unverify

    @candidate = Candidate.find(params[:id])

    render_called = event_with_picture_update_private(PickConfirmationName, true)

    render :pick_confirmation_name_verify unless render_called
  end

  # edit sponsor_agreement verify
  #
  # === Attributes:
  #
  # * <tt>:id</tt> Candidate id
  #
  def sponsor_agreement_verify
    @is_verify = true
    @candidate = Candidate.find(params[:id])
  end

  # update sponsor_agreement verify
  #
  # === Attributes:
  #
  # * <tt>:commit</tt> legal values
  # ** <code>views.common.un_verify</code>
  # * <tt>:id</tt> Candidate id
  #
  def sponsor_agreement_verify_update
    is_unverify = params[:commit] == I18n.t('views.common.un_verify')

    candidate_id = params[:id]
    event_name = I18n.t('events.sponsor_agreement')
    @candidate = Candidate.find(candidate_id)
    candidate_event = @candidate.get_candidate_event(event_name)

    return admin_unverified_private(@candidate, candidate_event) if is_unverify

    @candidate = Candidate.find(candidate_id)
    render_called = agreement_update_private(event_name, 'sponsor_agreement', I18n.t('label.sponsor_agreement.sponsor_agreement'), true)
    @is_verify = true
    render :sponsor_agreement_verify unless render_called
  end

  protected

  def resource_class
    devise_mapping.to
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
