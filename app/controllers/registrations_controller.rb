# frozen_string_literal: true

#
# Handles Registration tasks
#
class RegistrationsController < Devise::RegistrationsController
  before_action :authenticate_admin!
  skip_before_action :require_no_authentication, only: [:new]

  # new Candidate
  #
  def new
    if admin_signed_in?
      super
    else
      # if use new_admin_registration_path then get
      # in an infintem redirect loop
      redirect_back fallback_location: show_visitor_path,
                    alert: I18n.t('messages.admin_login_needed',
                                  message: I18n.t('messages.another_admin'))
    end
  end

  # create Candidate
  #
  def create
    cs = params['candidate']['candidate_sheet_attributes']
    params['candidate'][:account_name] = Candidate.genertate_account_name(cs['last_name'], cs['first_name'])
    params['candidate'][:password] = '12345678'
    params['candidate'][:password_confirmation] = '12345678'
    super_create do |res|
      res.valid? # copied from super_create
      AppFactory.add_candidate_events(res)
      res.candidate_sheet.validate_emails # no longer part of save
      res.propagate_errors_up(res.candidate_sheet, true)
      if res.errors.any?
        flash.now.alert = I18n.t('views.common.save_failed', failee: "#{cs['first_name']} #{cs['last_name']}")
      else
        event_key = CandidateSheet.event_key
        candidate_event = res.get_candidate_event(event_key)
        candidate_event.mark_completed(res.validate_creation_complete(CandidateSheet), CandidateSheet)
        res.save
        if candidate_event.save
          flash.now.notice = I18n.t('views.candidates.created', account: res.account_name, name: res.first_last_name)
        else
          flash.now.alert = I18n.t('views.common.save_failed', failee: "#{cs['first_name']} #{cs['last_name']}")
        end
      end
    end
  end

  # destroy Candidate
  #
  def destroy
    if admin_signed_in?
      super
    else
      redirect_to :back, alert: I18n.t('messages.admin_login_needed', message: I18n.t('messages.remove_candidate'))
    end
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

  private

  # This is a modified copy of super for create
  #
  def super_create
    build_resource(sign_up_params)
    # resource.save
    yield resource if block_given?
    if resource.persisted?
      expire_data_after_sign_in!
      redirect_to new_candidate_url,
                  notice: I18n.t('views.candidates.created',
                                 account: resource.account_name,
                                 name: resource.first_last_name)
      # end
    else
      clean_up_passwords resource
      set_minimum_password_length
      @candidate = resource
      cs = params['candidate']['candidate_sheet_attributes']
      # the problem being solved is the first time through a candidate would be created & would
      # go to create.html.erb, which would fail the second time through.  So it is re-directed back
      # to new.html.erb
      respond_with resource,
                   location: new_candidate_url,
                   alert: I18n.t('views.common.save_failed', failee: "#{cs['first_name']} #{cs['last_name']}")
    end
  end

  def after_inactive_sign_up_path_for(_resource)
    new_candidate_url
  end
end
