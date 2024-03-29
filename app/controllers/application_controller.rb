# frozen_string_literal: true

#
# Handles Common Application tasks
#
class ApplicationController < ActionController::Base
  include ApplicationHelper
  before_action :set_locale
  before_action :configure_permitted_parameters, if: :devise_controller?

  attr_accessor :candidate_info

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # map  from candidate_event status to css class
  # it should match candidate_event.status
  #
  # === Parameters:
  #
  # * <tt>:candidate_event</tt> CandidateEvent
  #
  def event_class(candidate_event)
    case candidate_event.status
    when I18n.t('status.not_started')
      'event-unitialized'
    when I18n.t('status.coming_due')
      'event-coming-due'
    when I18n.t('status.late')
      'event-late'
    when I18n.t('status.awaiting_candidate')
      'event-awaiting-candidate'
    when I18n.t('status.awaiting_admin')
      'event-awaiting-verification'
    when I18n.t('status.verified')
      'event-completed'
    else
      raise("Unknown candidate_event status = #{candidate_event.status}")
    end
  end

  # sets info for _sorting_candidate_selection.html.erb
  #
  # === Parameters:
  #
  # * <tt>:args</tt> optional args
  #
  def candidates_info(args = { direction: :asc, sort: :account_name })
    args = { confirmation_event: nil, selected_candidate_ids: [] }.merge(args)
    args = args.merge(direction: params[:direction]) unless params[:direction].nil?
    args = args.merge(sort: params[:sort]) unless params[:sort].nil?
    @confirmation_event = args[:confirmation_event]
    @selected_candidate_ids = args[:selected_candidate_ids]
    ce_id = @confirmation_event&.id
    args[:event_id] = ce_id
    @candidate_info = PluckCan.pluck_candidates(args)
  end

  protected

  def configure_permitted_parameters
    if devise_mapping.name == :admin
      devise_parameter_sanitizer.permit(:sign_up) do |u|
        u.permit(:name, :password, :password_confirmation, :remember_me)
      end
      devise_parameter_sanitizer.permit(:sign_in) { |u| u.permit(:account_name, :password, :remember_me) }
      devise_parameter_sanitizer.permit(:account_update) do |u|
        u.permit(:name, :email, :contact_name, :contact_phone, :password, :password_confirmation, :current_password)
      end
    else
      # admin is editing a candidate's account info
      devise_parameter_sanitizer.permit(:sign_in) do |candidate_parms|
        candidate_parms.permit(:account_name, :password, :remember_me, :parent_email_1)
      end
      devise_parameter_sanitizer.permit(:sign_up) do |candidate_parms|
        candidate_parms.permit(*candidate_permitted_params)
      end
      devise_parameter_sanitizer.permit(:account_update) do |candidate_parms|
        candidate_parms.permit(*(candidate_signed_in? ? [:current_password] : []), *candidate_permitted_params)
      end
    end
  end

  def candidate_params
    params.require(:candidate).permit(candidate_permitted_params)
  end

  def certificate_file_params
    params.require(:candidate).permit(baptismal_certificate_attributes: [:scanned_certificate])
  end

  def sponsor_eligibility_file_params
    params.require(:candidate).permit(sponsor_covenant_attributes: [:scanned_eligibility])
  end

  # TODO: Remove?
  def pick_confirmation_name_file_params
    attribute_names = %i[pick_confirmation_name_filename
                         pick_confirmation_name_content_type
                         pick_confirmation_name_file_contents]
    params.require(:candidate).permit(pick_confirmation_name_attributes: attribute_names)
  end

  def candidate_permitted_params
    Candidate.permitted_params
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) ||
      if resource.is_a?(Candidate)
        if candidate_signed_in?
          event_candidate_registration_url(resource.id)
        else
          candidate_url(resource.id)
        end
      elsif admin_signed_in?
        admin_path(resource.id)
      else
        super
      end
  end

  private

  def extract_locale_from_accept_language_header
    request.env['HTTP_ACCEPT_LANGUAGE']&.scan(/^[a-z]{2}/)&.first
  end

  def set_locale
    I18n.locale = extract_locale_from_accept_language_header || I18n.default_locale
  rescue I18n::InvalidLocale => e
    # if try to locale to Russian(ru) an error is raised, so catch it & use I18n.default_local
    loc = "Encounter the following error while trying to set the locale: ''#{e.message}'.  Setting to default_locale,'"
    Rails.logger.error(loc)
    I18n.default_locale
  end
end
