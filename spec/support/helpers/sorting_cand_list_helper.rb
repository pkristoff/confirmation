module SortingCandListHelpers

  def expect_sorting_candidate_list(column_headers_in_order, candidates_in_order, rendered_or_page, confirmation_event = nil)

    table_id = "table[id='candidate_list_table']"
    tr_header_id = "tr[id='candidate_list_header']"

    expect(rendered_or_page).to have_css("#{table_id}")
    expect(rendered_or_page).to have_css("#{table_id} #{tr_header_id}")

    column_headers_in_order.each_with_index do |info, index|
      i18n_name = info[0]
      sort_enabled = info[1]
      th_header_id = "candidate_list_header_th_#{index + 1}"
      basic_th_css = "#{table_id} #{tr_header_id} [id='#{th_header_id}']"
      # expect headers
      if sort_enabled
        expect(rendered_or_page).to have_css basic_th_css, text: i18n_name
      else
        expect(rendered_or_page).to have_css "#{basic_th_css}[class='sorter-false filter-false#{i18n_name === I18n.t('views.nav.edit') ? ' edit_column_header' : ''}']" unless i18n_name === I18n.t('label.candidate_event.select')
        expect(rendered_or_page).to have_css "#{basic_th_css}[class='sorter-false filter-false select_column_header'] input[id='select_all_none_input']" if i18n_name === I18n.t('label.candidate_event.select')
      end
    end
    expect(rendered_or_page).to have_css "#{table_id} #{tr_header_id} th", count: column_headers_in_order.size #  checkbox
    #expect table cells
    candidates_in_order.each do |candidate|
      tr_id = "tr[id='candidate_list_tr_#{candidate.id}']"
      column_headers_in_order.each_with_index do |info, td_index|
        td_index_adj = td_index
        td_id = "td[id=tr#{candidate.id}_td#{td_index_adj}]"
        text = nil
        cell_access_path = info[2]
        cell_expect_function = info[3]
        if cell_access_path.empty?
          cell_expect_function.call(candidate, rendered_or_page, td_index_adj)
        elsif confirmation_event && (cell_access_path[0] === :completed_date or cell_access_path[0] === :verified)
          text = candidate.get_candidate_event(confirmation_event.name).method(cell_access_path[0]).call
          expect(rendered_or_page).to have_css "#{table_id} #{tr_id} #{td_id}", text: text
        elsif cell_access_path[0] === :candidate_event
          candidate_event = candidate.get_candidate_event(cell_access_path[1])
          expect(rendered_or_page).to have_css "#{table_id} #{tr_id} #{td_id}", text: candidate_event.method(cell_access_path[2]).call
        else
          text = candidate.method(cell_access_path[0]).call if cell_access_path.size === 1
          text = candidate.method(cell_access_path[0]).call.method(cell_access_path[1]).call if cell_access_path.size === 2
          expect(rendered_or_page).to have_css "#{table_id} #{tr_id} #{td_id}", text: text
        end
      end
      expect(rendered_or_page).to have_css "#{table_id} #{tr_id} td", count: column_headers_in_order.size #  checkbox
    end
    expect(rendered_or_page).to have_css "#{table_id} tr", count: candidates_in_order.size + 1
  end
  #
  # class CandidateSheet
  #   def route_path(candidate_id)
  #     candidate_sheet_path(candidate_id)
  #   end
  #   def route_path_verify(candidate_id)
  #     candidate_sheet_path(candidate_id)
  #   end
  # end
  #
  # class BaptismalCertificate
  #   def route_path(candidate_id)
  #     event_with_picture_path(candidate_id, Event::Route::BAPTISMAL_CERTIFICATE)
  #   end
  #   def route_path_verify(candidate_id)
  #     event_with_picture_path(candidate_id, Event::Route::BAPTISMAL_CERTIFICATE)
  #   end
  # end
  #
  # class SponsorCovenant
  #   def route_path(candidate_id)
  #     event_with_picture_path(candidate_id, Event::Route::SPONSOR_COVENANT)
  #   end
  #   def route_path_verify(candidate_id)
  #     event_with_picture_path(candidate_id, Event::Route::SPONSOR_COVENANT)
  #   end
  # end
  #
  # class PickConfirmationName
  #   def route_path(candidate_id)
  #     pick_confirmation_name_path(candidate_id)
  #   end
  #   def route_path_verify(candidate_id)
  #     pick_confirmation_name_verify_path(candidate_id)
  #   end
  # end
  #
  # class SponsorCovenant
  #   def route_path(candidate_id)
  #     sponsor_agreement_path(candidate_id)
  #   end
  #   def route_path_verify(candidate_id)
  #     sponsor_agreement_path(candidate_id)
  #   end
  # end
  #
  # class ChristianMinistry
  #   def route_path(candidate_id)
  #     christian_ministry_path(candidate_id)
  #   end
  #   def route_path_verify(candidate_id)
  #     christian_ministry_path(candidate_id)
  #   end
  # end
  #
  # class RetreatVerification
  #   def route_path(candidate_id)
  #     event_with_picture_path(candidate_id, Event::Route::RETREAT_VERIFICATION)
  #   end
  #   def route_path_verify(candidate_id)
  #     event_with_picture_path(candidate_id, Event::Route::RETREAT_VERIFICATION)
  #   end
  # end

  def event_name_to_path (event_name, candidate_id)
    case event_name
      when I18n.t('events.candidate_covenant_agreement')
        sign_agreement_path(candidate_id)
      when I18n.t('events.candidate_information_sheet')
        candidate_sheet_path(candidate_id)
      when I18n.t('events.baptismal_certificate')
        event_with_picture_path(candidate_id, Event::Route::BAPTISMAL_CERTIFICATE)
      when I18n.t('events.sponsor_covenant')
        event_with_picture_path(candidate_id, Event::Route::SPONSOR_COVENANT)
      when I18n.t('events.confirmation_name')
        pick_confirmation_name_path(candidate_id)
      when I18n.t('events.sponsor_agreement')
        sponsor_agreement_path(candidate_id)
      when I18n.t('events.candidate_covenant_agreement')
        sign_agreement_path(candidate_id)
      when I18n.t('events.christian_ministry')
        christian_ministry_path(candidate_id)
      when I18n.t('events.retreat_verification')
        event_with_picture_path(candidate_id, Event::Route::RETREAT_VERIFICATION)
      when I18n.t('events.parent_meeting')
        event_candidate_path(candidate_id, anchor: "event_id_#{ConfirmationEvent.find_by_name(event_name).id}")
      else
        "Unknown event_name: #{event_name}"
    end
  end

  def event_name_to_path_verify (event_name, candidate_id)
    case event_name
      when I18n.t('events.candidate_covenant_agreement')
        sign_agreement_verify_path(candidate_id)
      when I18n.t('events.candidate_information_sheet')
        candidate_sheet_verify_path(candidate_id)
      when I18n.t('events.baptismal_certificate')
        event_with_picture_verify_path(candidate_id, Event::Route::BAPTISMAL_CERTIFICATE)
      when I18n.t('events.sponsor_covenant')
        event_with_picture_verify_path(candidate_id, Event::Route::SPONSOR_COVENANT)
      when I18n.t('events.confirmation_name')
        pick_confirmation_name_verify_path(candidate_id)
      when I18n.t('events.sponsor_agreement')
        sponsor_agreement_verify_path(candidate_id)
      when I18n.t('events.candidate_covenant_agreement')
        sign_agreement_path(candidate_id)
      when I18n.t('events.christian_ministry')
        christian_ministry_verify_path(candidate_id)
      when I18n.t('events.retreat_verification')
        event_with_picture_verify_path(candidate_id, Event::Route::RETREAT_VERIFICATION)
      when I18n.t('events.parent_meeting')
        event_candidate_path(candidate_id, anchor: "event_id_#{ConfirmationEvent.find_by_name(event_name).id}")
      else
        "Unknown event_name: #{event_name}"
    end
  end

  def expect_event(event_name, verify=false)
    lambda {|candidate, rendered, td_index|
      href = verify ? event_name_to_path_verify(event_name, candidate.id):event_name_to_path(event_name, candidate.id)
      expect(rendered).to have_css("table[id='candidate_list_table'] tr[id='candidate_list_tr_#{candidate.id}'] td[id=tr#{candidate.id}_td#{td_index}] a[href='#{href}']",
                                   text: candidate.get_candidate_event(event_name).status)
    }
  end

  def expect_select_checkbox
    lambda {|candidate, rendered, td_index| expect(rendered).to have_css "td[id=tr#{candidate.id}_td#{td_index}] input[type=checkbox][id=candidate_candidate_ids_#{candidate.id}]"}
  end

  def candidates_columns
    cols = common_columns
    cols.insert(1, [I18n.t('views.nav.edit'), false, '', lambda {|candidate, rendered, td_index| expect(rendered).to have_css "td[id='tr#{candidate.id}_td#{td_index}']"}])
    cols << [I18n.t('views.candidates.account_confirmed'), true, '', expect_account_confirmed]
    cols << [I18n.t('views.candidates.password_changed'), true, '', expect_password_changed]
    cols
  end

  def candidate_events_columns(confirmation_event = nil)
    if confirmation_event.nil?
      cols = common_columns
    else
      cols = common_non_event_columns
    end
    cols.insert(1,
                [I18n.t('views.events.completed_date'), true, [:completed_date]],
                [I18n.t('views.events.verified'), true, [:verified]])
    unless confirmation_event.nil?
      cols.append(
          [confirmation_event.name, true, '', expect_event(confirmation_event.name, true)]
      )
    end
    cols
  end

  def confirmation_events_columns (confirmation_event_name)
    cols = common_non_event_columns
    cols.insert(
        1,
        [I18n.t('views.events.completed_date'), true, [:candidate_event, confirmation_event_name, :completed_date]],
        [I18n.t('views.events.verified'), true, [:candidate_event, confirmation_event_name, :verified]]
    )
    cols.append(
        [I18n.t('events.confirmation_name'), true, '', expect_event(I18n.t('events.confirmation_name'), true)]
    )
    cols
  end

  def common_columns
    columns = common_non_event_columns
    columns.insert(columns.length-1, [I18n.t('label.candidate_sheet.grade'), true, [:candidate_sheet, :grade]])
    columns.concat common_event_columns
  end

  def common_non_event_columns
    [
        [I18n.t('label.candidate_event.select'), false, '', expect_select_checkbox],
        [I18n.t('label.candidate_sheet.last_name'), true, [:candidate_sheet, :last_name]],
        [I18n.t('label.candidate_sheet.first_name'), true, [:candidate_sheet, :first_name]],
        [I18n.t('label.candidate_sheet.attending'), true, [:candidate_sheet, :attending]],
    ]
  end

  def common_event_columns
    [
        [I18n.t('events.candidate_covenant_agreement'), true, '', expect_event(I18n.t('events.candidate_covenant_agreement'))],
        [I18n.t('events.candidate_information_sheet'), true, '', expect_event(I18n.t('events.candidate_information_sheet'))],
        [I18n.t('events.baptismal_certificate'), true, '', expect_event(I18n.t('events.baptismal_certificate'))],
        [I18n.t('events.sponsor_covenant'), true, '', expect_event(I18n.t('events.sponsor_covenant'))],
        [I18n.t('events.confirmation_name'), true, '', expect_event(I18n.t('events.confirmation_name'))],
        [I18n.t('events.sponsor_agreement'), true, '', expect_event(I18n.t('events.sponsor_agreement'))],
        [I18n.t('events.christian_ministry'), true, '', expect_event(I18n.t('events.christian_ministry'))],
        [I18n.t('events.retreat_verification'), true, '', expect_event(I18n.t('events.retreat_verification'))],
        [I18n.t('events.parent_meeting'), true, '', expect_event(I18n.t('events.parent_meeting'))]
    ]
  end

  def expect_mass_edit_candidates_event(confirmation_event, candidate, updated_message)
    expect_message(:flash_notice, updated_message) unless updated_message.nil?

    expect(page).to have_css "form[action='/mass_edit_candidates_event_update/#{confirmation_event.id}']"

    expect(page).to have_css("input[type='submit'][value='#{I18n.t('views.common.update')}']", count: 2)

    expect(page).to have_css("input[id='top-update'][type='submit'][value='#{I18n.t('views.common.update')}']")

    expect(page).to have_css 'input[type=checkbox][id=verified][value="1"]'
    expect(page).to have_field(I18n.t('views.events.verified'))
    expect(page).to have_field(I18n.t('views.events.completed_date'))

    expect_sorting_candidate_list(
        candidate_events_columns(confirmation_event),
        [candidate],
        page,
        confirmation_event)

    expect(candidate.get_candidate_event(confirmation_event.name).completed_date).to eq(Date.today) unless updated_message.nil?
    expect(candidate.get_candidate_event(confirmation_event.name).verified).to eq(true) unless updated_message.nil?
  end

  def expect_pick_confirmation_name_form(cand_id, path_str, dev_path, update_id, values = {})

    with_values = !(values[:saint_name].nil? || values[:saint_name].empty?)

    if with_values
      saint_name = SAINT_NAME
    else
      saint_name = values[:saint_name]
    end

    expect_messages(values[:expect_messages]) unless values[:expect_messages].nil?

    cand = Candidate.find(cand_id)
    expect_heading(cand, dev_path.empty?, I18n.t('events.confirmation_name'))

    expect(page).to have_selector("form[id=edit_candidate][action=\"/#{dev_path}#{path_str}.#{cand_id}\"]")

    expect_field(I18n.t('label.confirmation_name.saint_name'), with_values ? saint_name : '')

    expect(page).to have_button(update_id)
    expect_download_button(Event::Document::CONFIRMATION_NAME, cand_id, dev_path)
  end

  def expect_heading(cand, isDev, event_name)
    first = cand.candidate_sheet.first_name
    last = cand.candidate_sheet.last_name

    if isDev
      expect(page).to have_selector("h2[id=heading]", text: "#{I18n.t('views.events.heading', event_name: event_name, first: first, last: last)}")
    else
      expect(page).to have_selector("h2[id=heading]", text: "#{event_name}")
      expect(page).not_to have_selector("h2[id=heading]", text: "#{I18n.t('views.events.heading', event_name: event_name, first: first, last: last)}")
    end
  end

  def expect_christian_ministry_form(cand_id, path_str, dev_path, update_id, values = {})

    with_values = !(values[:what_service].nil? || values[:what_service].empty?)
    with_values = with_values || !(values[:where_service].nil? || values[:where_service].empty?)
    with_values = with_values || !(values[:when_service].nil? || values[:when_service].empty?)
    with_values = with_values || !(values[:helped_me].nil? || values[:helped_me].empty?)

    expect_messages(values[:expect_messages]) unless values[:expect_messages].nil?

    cand = Candidate.find(cand_id)
    expect_heading(cand, dev_path.empty?, I18n.t('events.christian_ministry'))

    expect(page).to have_selector("form[id=edit_candidate][action=\"/#{dev_path}#{path_str}.#{cand_id}\"]")

    expect_field(I18n.t('label.christian_ministry.what_service'), with_values ? values[:what_service] : '')
    expect_field(I18n.t('label.christian_ministry.where_service'), with_values ? values[:where_service] : '')
    expect_field(I18n.t('label.christian_ministry.when_service'), with_values ? values[:when_service] : '')
    expect_field(I18n.t('label.christian_ministry.helped_me'), with_values ? values[:helped_me] : '')

    expect(page).to have_button(update_id)
    expect_download_button(Event::Document::CHRISTIAN_MINISTRY, cand_id, dev_path)
  end

private
  def expect_field (label, value)
    if value.nil? or value === ''
      expect(page).to have_field(label)
    else
      expect(page).to have_field(label, with: value)
    end
  end

end