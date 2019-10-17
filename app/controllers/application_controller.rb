# frozen_string_literal: true

#
# Handles Common Application tasks
#
class ApplicationController < ActionController::Base
  include ApplicationHelper
  before_action :configure_permitted_parameters, if: :devise_controller?

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

  protected

  def configure_permitted_parameters
    if devise_mapping.name == :admin
      devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit(:name, :password, :password_confirmation, :remember_me) }
      devise_parameter_sanitizer.permit(:sign_in) { |u| u.permit(:account_name, :password, :remember_me) }
      devise_parameter_sanitizer.permit(:account_update) { |u| u.permit(:name, :email, :contact_name, :contact_phone, :password, :password_confirmation, :current_password) }
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
    params.require(:candidate).permit(pick_confirmation_name_attributes: %i[pick_confirmation_name_filename pick_confirmation_name_content_type pick_confirmation_name_file_contents])
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

  # sets info for _sorting_candidate_selection.html.erb
  #
  # === Parameters:
  #
  # * <tt>_selected_candidate_ids_</tt> Array of initially selected candidates
  # * <tt>_confirmation_event_</tt> Confirmation event used for mass update of candidate event for candidates.
  #
  def candidates_info(args = {})
    args = { confirmation_event: nil, selected_candidate_ids: [] }.merge(args)
    @confirmation_event = args[:confirmation_event]
    @selected_candidate_ids = args[:selected_candidate_ids]
    ce_id = @confirmation_event.nil? ? nil : @confirmation_event.id
    @candidate_info = PluckCan.pluck_candidates(ce_id)
  end
end
