# frozen_string_literal: true

#
# Handles Registration tasks
#
class RegistrationsController < Devise::RegistrationsController
  before_action :authenticate_admin!
  skip_before_action :require_no_authentication, only: [:new]

  # create Candidate
  #
  def create
    @candidate = AppFactory.create_candidate
    cs = params['candidate']['candidate_sheet_attributes']
    params['candidate'][:account_name] = "#{cs['last_name']}#{cs['first_name']}".downcase
    params['candidate'][:password] = '12345678'
    params['candidate'][:password_confirmation] = '12345678'

    if @candidate.update(candidate_params)
      event_key = CandidateSheet.event_key
      candidate_event = @candidate.get_candidate_event(event_key)
      candidate_event.mark_completed(@candidate.validate_creation_complete(CandidateSheet), CandidateSheet)
      if candidate_event.save
        redirect_to new_candidate_url, notice: I18n.t('views.candidates.created', account: @candidate.account_name, name: @candidate.first_last_name)
      else
        redirect_back fallback_location: ref_url, alert: I18n.t('views.common.save_failed', failee: event_key)
      end
    else
      flash['alert'] = I18n.t('views.common.save_failed', failee: "#{cs['first_name']} #{cs['last_name']}")
    end
  end

  # destroy Candidate
  #
  def destroy
    return redirect_to :back, alert: I18n.t('messages.admin_login_needed', message: I18n.t('messages.remove_candidate')) unless admin_signed_in?

    super
  end

  # new Candidate
  #
  def new
    return redirect_back fallback_location: new_admin_registration_path, alert: I18n.t('messages.admin_login_needed', message: I18n.t('messages.another_admin')) unless admin_signed_in?

    super
  end

  # return current_candidate
  #
  # === Parameters:
  #
  # * <tt>:resource_or_scope</tt> Not used
  #
  # === Returns:
  #
  # * <tt>Candidate</tt>
  #
  def after_update_path_for(_resource_or_scope)
    current_candidate
  end

  # update resource
  #
  # === Parameters:
  #
  # * <tt>:resource</tt> being updated
  # * <tt>:params</tt> new values
  #
  def update_resource(resource, params)
    params.delete(:current_password)
    resource.update_without_password(params)
  end

  # devise mapping for candidate
  #
  def devise_mapping
    mapping = super
    mapping = Devise.mappings[:candidate] if mapping.nil?
    mapping
  end

  protected

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

  def sign_up(_resource_name, _resource)
    true # don't sign_in new candidate after signup.
  end

  def event; end
end
