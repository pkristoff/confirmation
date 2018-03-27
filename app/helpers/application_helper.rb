# require_relative '../../External Libraries/'

module ApplicationHelper
  def sortable(column, title, route, confirmation_event_id='')
    title ||= column.titleize
    css_class = column == sort_column(params[:sort]) ? "current #{sort_direction(params[:direction]) == 'asc' ? 'glyphicon glyphicon-arrow-up' : 'glyphicon glyphicon-arrow-down'}" : nil
    direction = column == sort_column(params[:sort]) && sort_direction(params[:direction]) == 'asc' ? 'desc' : 'asc'
    path = 'unknown path'
    path = monthly_mass_mailing_path(sort: column, direction: direction, class: css_class, update: {confirmation_event_id => ''}) if route === :monthly_mass_mailing
    path = mass_edit_candidates_event_path(id: confirmation_event_id, sort: column, direction: direction, class: css_class, update: {confirmation_event_id => ''}) if route === :mass_edit_candidates_event
    path = candidates_path(sort: column, direction: direction, class: css_class) if route === :candidates
    link_to title, path, method: :get
  end

  # private - test only
  def sort_column(sort_column)
    columns = CandidateSheet.permitted_params.map {|attr| "candidate_sheet.#{attr}"}
    columns << 'account_name'
    columns << 'completed_date'
    columns.include?(sort_column) ? sort_column : 'account_name'
  end

  def sort_direction(direction)
    %w[asc desc].include?(direction) ? direction : 'asc'
  end

  def candidate_event_to_path(confirmation_event_name, candidate_id)
    # for some reason when this was in-lined in _side_bar it handled
    # admin vs. candidate.
    is_candidate_logged_in = current_admin.nil?
    case confirmation_event_name
      when I18n.t('events.candidate_covenant_agreement')
        if is_candidate_logged_in
          dev_sign_agreement_path(candidate_id)
        else
          sign_agreement_path(candidate_id)
        end
      when I18n.t('events.candidate_information_sheet')
        if is_candidate_logged_in
          dev_candidate_sheet_path(candidate_id)
        else
          candidate_sheet_path(candidate_id)
        end
      when I18n.t('events.baptismal_certificate')
        if is_candidate_logged_in
          dev_event_with_picture_path(candidate_id, Event::Route::BAPTISMAL_CERTIFICATE)
        else
          event_with_picture_path(candidate_id, Event::Route::BAPTISMAL_CERTIFICATE)
        end

      when I18n.t('events.sponsor_covenant')
        if is_candidate_logged_in
          dev_event_with_picture_path(candidate_id, Event::Route::SPONSOR_COVENANT)
        else
          event_with_picture_path(candidate_id, Event::Route::SPONSOR_COVENANT)
        end

      when I18n.t('events.confirmation_name')
        if is_candidate_logged_in
          dev_pick_confirmation_name_path(candidate_id)
        else
          pick_confirmation_name_path(candidate_id)
        end
      when I18n.t('events.sponsor_agreement')
        if is_candidate_logged_in
          dev_sponsor_agreement_path(candidate_id)
        else
          sponsor_agreement_path(candidate_id)
        end
      when I18n.t('events.christian_ministry')
        if is_candidate_logged_in
          dev_christian_ministry_path(candidate_id)
        else
          christian_ministry_path(candidate_id)
        end
      when I18n.t('events.retreat_verification')
        if is_candidate_logged_in
          dev_event_with_picture_path(candidate_id, Event::Route::RETREAT_VERIFICATION)
        else
          event_with_picture_path(candidate_id, Event::Route::RETREAT_VERIFICATION)
        end

      when I18n.t('events.parent_meeting')
        if is_candidate_logged_in
          dev_event_with_picture_path(candidate_id, Event::Other::PARENT_INFORMATION_MEETING)
        else
          event_with_picture_path(candidate_id, Event::Other::PARENT_INFORMATION_MEETING)
        end

      else
        raise "Unknown candidate_event_to_path: #{confirmation_event_name}"
    end
  end

  # used to show selection of sidebar links
  def active_tab_class(*paths)
    active = false
    # originally used current_page? but it did not work when update button was called.
    paths.each {|path| active ||= path === request.path}
    active ? 'active' : ''
  end
end
