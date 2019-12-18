# frozen_string_literal: true

#
# Application Helper
#
module ApplicationHelper
  # return link for sortable column
  #
  # === Parameters:
  #
  # * <tt>:column</tt>
  # * <tt>:title</tt>
  # * <tt>:route</tt>
  # * <tt>:confirmation_event_id</tt>
  #
  # === Returns:
  #
  # * <tt>String</tt>
  #
  def sortable(column, title, route, confirmation_event_id = '')
    title ||= column.titleize
    css_class = if column == sort_column(params[:sort])
                  "current #{sort_direction(params[:direction]) == 'asc' ? 'glyphicon glyphicon-arrow-up' : 'glyphicon glyphicon-arrow-down'}"
                end
    direction = column == sort_column(params[:sort]) && sort_direction(params[:direction]) == 'asc' ? 'desc' : 'asc'
    path = 'unknown path'
    path = monthly_mass_mailing_path(sort: column, direction: direction, class: css_class, update: { confirmation_event_id => '' }) if route == :monthly_mass_mailing
    path = mass_edit_candidates_event_path(id: confirmation_event_id, sort: column, direction: direction, class: css_class, update: { confirmation_event_id => '' }) if route == :mass_edit_candidates_event
    path = candidates_path(sort: column, direction: direction, class: css_class) if route == :candidates
    link_to title, path, method: :get
  end

  # private - test only
  # Sort direction
  #
  # === Parameters:
  #
  # * <tt>:sort_column</tt>
  #
  # === Returns:
  #
  # * <tt>String</tt>
  #
  def sort_column(sort_column)
    columns = CandidateSheet.permitted_params.map { |attr| "candidate_sheet.#{attr}" }
    columns << 'account_name'
    columns << 'completed_date'
    columns.include?(sort_column) ? sort_column : 'account_name'
  end

  # Sort direction
  #
  # === Parameters:
  #
  # * <tt>:direction</tt>
  # ** <code>acs</code>
  # ** <code>desc</code>
  #
  # === Returns:
  #
  # * <tt>String</tt>
  #
  def sort_direction(direction)
    %w[asc desc].include?(direction) ? direction : 'asc'
  end

  # used to show selection of sidebar links
  #
  # === Parameters:
  #
  # * <tt>:confirmation_event_key</tt>
  # ** <code>events.candidate_covenant_agreement</code>
  # ** <code>events.candidate_information_sheet</code>
  # ** <code>events.baptismal_certificate</code>
  # ** <code>events.sponsor_covenant</code>
  # ** <code>events.confirmation_name</code>
  # ** <code>events.retreat_verification</code>
  # ** <code>events.parent_meeting</code>
  # * <tt>:candidate_id</tt>
  #
  # === Returns:
  #
  # * <tt>String</tt> path(route)
  # * <tt>String</tt> I18n translation
  #
  def candidate_event_to_path(confirmation_event_key, candidate_id)
    # for some reason when this was in-lined in _side_bar it handled
    # admin vs. candidate.
    is_candidate_logged_in = current_admin.nil?
    case confirmation_event_key
    when Candidate.covenant_agreement_event_key
      if is_candidate_logged_in
        [dev_sign_agreement_path(candidate_id, Event::Other::CANDIDATE_COVENANT_AGREEMENT), t('label.sidebar.candidate_covenant_agreement')]
      else
        [sign_agreement_path(candidate_id, Event::Other::CANDIDATE_COVENANT_AGREEMENT), t('label.sidebar.candidate_covenant_agreement')]
      end
    when CandidateSheet.event_key
      if is_candidate_logged_in
        [dev_candidate_sheet_path(candidate_id, Event::Other::CANDIDATE_INFORMATION_SHEET), t('label.sidebar.candidate_information_sheet')]
      else
        [candidate_sheet_path(candidate_id, Event::Other::CANDIDATE_INFORMATION_SHEET), t('label.sidebar.candidate_information_sheet')]
      end
    when BaptismalCertificate.event_key
      if is_candidate_logged_in
        [dev_event_with_picture_path(candidate_id, Event::Route::BAPTISMAL_CERTIFICATE), t('label.sidebar.baptismal_certificate')]
      else
        [event_with_picture_path(candidate_id, Event::Route::BAPTISMAL_CERTIFICATE), t('label.sidebar.baptismal_certificate')]
      end
    when SponsorCovenant.event_key
      if is_candidate_logged_in
        [dev_event_with_picture_path(candidate_id, Event::Route::SPONSOR_COVENANT), I18n.t('label.sidebar.sponsor_covenant')]
      else
        [event_with_picture_path(candidate_id, Event::Route::SPONSOR_COVENANT), I18n.t('label.sidebar.sponsor_covenant')]
      end
    when PickConfirmationName.event_key
      if is_candidate_logged_in
        [dev_pick_confirmation_name_path(candidate_id, Event::Route::CONFIRMATION_NAME), t('label.sidebar.confirmation_name')]
      else
        [pick_confirmation_name_path(candidate_id, Event::Route::CONFIRMATION_NAME), t('label.sidebar.confirmation_name')]
      end
    when ChristianMinistry.event_key
      if is_candidate_logged_in
        [dev_christian_ministry_path(candidate_id, Event::Route::CHRISTIAN_MINISTRY), t('label.sidebar.christian_ministry')]
      else
        [christian_ministry_path(candidate_id, Event::Route::CHRISTIAN_MINISTRY), t('label.sidebar.christian_ministry')]
      end
    when RetreatVerification.event_key
      if is_candidate_logged_in
        [dev_event_with_picture_path(candidate_id, Event::Route::RETREAT_VERIFICATION), t('label.sidebar.retreat_verification')]
      else
        [event_with_picture_path(candidate_id, Event::Route::RETREAT_VERIFICATION), t('label.sidebar.retreat_verification')]
      end
    when Candidate.parent_meeting_event_key
      if is_candidate_logged_in
        [dev_event_with_picture_path(candidate_id, Event::Other::PARENT_INFORMATION_MEETING), t('label.sidebar.parent_meeting')]
      else
        [event_with_picture_path(candidate_id, Event::Other::PARENT_INFORMATION_MEETING), t('label.sidebar.parent_meeting')]
      end
    else
      raise "Unknown candidate_event_to_path: #{confirmation_event_name}"
    end
  end

  # used to show selection of sidebar links
  #
  # === Parameters:
  #
  # * <tt>:paths</tt>
  #
  # === Returns:
  #
  # * <tt>String</tt>
  #
  def active_tab_class(*paths)
    active = false
    # originally used current_page? but it did not work when update button was called.
    paths.each { |path| active ||= path == request.path }
    active ? 'active' : ''
  end

  # common method for sanitizing html that is input by the administrator.
  #
  # === Parameters:
  #
  # * <tt>:html</tt> string to be sanitize
  #
  # === Returns:
  #
  # * <tt>String</tt> of sanitized html.
  #
  def app_sanitize(html)
    sanitize(html, attributes: %w[style])
  end
end
