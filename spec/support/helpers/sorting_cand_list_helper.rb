# frozen_string_literal: true

# SortingCandListHelpers
#
module SortingCandListHelpers
  # https://forum.jquery.com/topic/tablesorter-filter-functions-external-select-box-to-filter-by-column
  # expects sorting columns
  #
  # === Parameters:
  #
  # * <tt>:column_headers_in_order</tt>
  # * <tt>:candidates_in_order</tt>
  # * <tt>:rendered_or_page</tt>
  # * <tt>:confirmation_event</tt>
  #
  def expect_sorting_candidate_list(column_headers_in_order, candidates_in_order, rendered_or_page, confirmation_event = nil)
    table_id = "table[id='candidate_list_table']"
    tr_header_id = "tr[id='candidate_list_header']"
    expect(rendered_or_page).to have_css(table_id.to_s)
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
        case i18n_name
        when I18n.t('views.nav.status')
          expect(rendered_or_page).to have_css "#{basic_th_css}[class='sorter-true filter-true']"
        when I18n.t('views.nav.edit')
          expect(rendered_or_page).to have_css "#{basic_th_css}[class='sorter-false filter-false edit_column_header']"
        when I18n.t('views.nav.note')
          expect(rendered_or_page).to have_css "#{basic_th_css}[class='sorter-false filter-false']"
        when I18n.t('label.candidate_event.select')
          # handles checkbox
          # rubocop:disable Layout/LineLength
          expect(rendered_or_page).to have_css "#{basic_th_css}[class='sorter-false filter-false select_column_header'] input[id='select_all_none_input']"
          # rubocop:enable Layout/LineLength
        else
          raise("unhandled i18n_name=#{i18n_name}")
        end
      end
    end
    expect(rendered_or_page).to have_css "#{table_id} #{tr_header_id} th", count: column_headers_in_order.size #  checkbox
    # expect table cells
    candidates_in_order.each do |candidate|
      cand_id = candidate.id
      tr_id = "tr[id='candidate_list_tr_#{cand_id}']"
      column_headers_in_order.each_with_index do |info, td_index|
        td_index_adj = td_index
        td_id = "td[id=tr#{cand_id}_td#{td_index_adj}]"
        text = nil
        cell_access_path = info[2]
        cell_expect_function = info[3]
        if cell_access_path.empty?
          cell_expect_function.call(cand_id, rendered_or_page, td_index_adj)
        elsif confirmation_event && (cell_access_path[0] == :completed_date || cell_access_path[0] == :verified)
          text = candidate.get_candidate_event(confirmation_event.event_key).method(cell_access_path[0]).call
          expect(rendered_or_page).to have_css "#{table_id} #{tr_id} #{td_id}", text: text
        elsif cell_access_path[0] == :candidate_event
          candidate_event = candidate.get_candidate_event(cell_access_path[1])
          expect(rendered_or_page).to have_css "#{table_id} #{tr_id} #{td_id}",
                                               text: candidate_event.method(cell_access_path[2]).call
        else
          text = candidate.method(cell_access_path[0]).call if cell_access_path.size == 1
          text = candidate.method(cell_access_path[0]).call.method(cell_access_path[1]).call if cell_access_path.size == 2
          expect(rendered_or_page).to have_css "#{table_id} #{tr_id} #{td_id}", text: text
        end
      end
      expect(rendered_or_page).to have_css "#{table_id} #{tr_id} td", count: column_headers_in_order.size #  checkbox
    end
    expect(rendered_or_page).to have_css "#{table_id} tr", count: candidates_in_order.size + 1
  end

  @event_key_to_path_offset = nil

  @event_key_to_path_verify_offset = nil

  # expect event
  #
  # === Parameters:
  #
  # * <tt>:event_key</tt>
  # * <tt>:verify</tt>
  #
  # === Returns:
  #
  # * <tt>:Lambda</tt> cand_id, rendered, td_index
  #
  def expect_event(event_key, verify: false)
    # rubocop:disable Layout/LineLength
    lambda { |cand_id, rendered, td_index|
      cand = Candidate.find_by(id: cand_id)
      href = verify ? event_key_to_path_verify(event_key, cand_id) : event_key_to_path(event_key, cand_id)
      expect(rendered).to have_css("table[id='candidate_list_table'] tr[id='candidate_list_tr_#{cand_id}'] td[id=tr#{cand_id}_td#{td_index}] a[href='#{href}']",
                                   text: cand.get_candidate_event(event_key).status)
    }
    # rubocop:enable Layout/LineLength
  end

  # expect select checkbox
  #
  # === Returns:
  #
  # * <tt>:Lambda</tt> cand_id, rendered, td_index
  #
  def expect_select_checkbox
    lambda do |cand_id, rendered, td_index|
      loc = "td[id=tr#{cand_id}_td#{td_index}] input[type=checkbox][id=candidate_candidate_ids_#{cand_id}]"
      expect(rendered).to have_css loc
    end
  end

  # return Candidate columns
  #
  # === Returns:
  #
  # * <tt>:Array</tt>
  #
  def candidates_columns
    # rubocop:disable Layout/LineLength
    cols = common_columns
    cols.insert(2, [I18n.t('views.nav.edit'), false, '', ->(cand_id, rendered, td_index) { expect(rendered).to have_css "td[id='tr#{cand_id}_td#{td_index}']" }])
    cols.insert(3, [I18n.t('views.nav.note'), false, '', expect_note])
    cols << [I18n.t('views.candidates.account_confirmed'), true, '', expect_account_confirmed]
    cols << [I18n.t('views.candidates.password_changed'), true, '', expect_password_changed]
    cols
    # rubocop:enable Layout/LineLength
  end

  # return Candidate event columns
  #
  # === Parameters:
  #
  # * <tt>:confirmation_event</tt>
  #
  # === Returns:
  #
  # * <tt>:Array</tt>
  #
  def candidate_events_columns(confirmation_event = nil)
    cols = confirmation_event.nil? ? common_columns : common_non_event_columns

    cols.insert(2,
                [I18n.t('views.events.completed_date'), true, [:completed_date]],
                [I18n.t('views.events.verified'), true, [:verified]])
    unless confirmation_event.nil?
      cols.append(
        [confirmation_event.event_key, true, '', expect_event(confirmation_event.event_key, verify: true)]
      )
    end
    cols
  end

  # Adding confirmation event columns to to the non-event columns
  #
  # === Parameters:
  #
  # * <tt>:event_key</tt>
  #
  # === Returns:
  #
  # * <tt>:Array</tt> of column info
  #
  def confirmation_events_columns(event_key)
    cols = common_non_event_columns
    cols.insert(
      2,
      [I18n.t('views.events.completed_date'), true, [:candidate_event, event_key, :completed_date]],
      [I18n.t('views.events.verified'), true, [:candidate_event, event_key, :verified]]
    )
    cols.append(
      [PickConfirmationName.event_key, true, '', expect_event(event_key, verify: true)]
    )
    cols
  end

  # common columns used for sorting
  #
  # === Returns:
  #
  # * <tt>:Array</tt> of column info
  #
  def common_columns
    columns = common_non_event_columns
    columns.insert(columns.length - 1, [I18n.t('activerecord.attributes.candidate_sheet.grade'), true, %i[candidate_sheet grade]])
    columns.insert(columns.length - 1, [I18n.t('activerecord.attributes.candidate_sheet.program_year'),
                                        true,
                                        %i[candidate_sheet program_year]])
    columns.concat common_event_columns
  end

  # Expect Mass Edit Candidates Event
  #
  # === Parameters:
  #
  # * <tt>:confirmation_event</tt>
  # * <tt>:cand_id</tt>
  # * <tt>:updated_message</tt>
  # * <tt>:is_unverified</tt>
  #
  def expect_mass_edit_candidates_event(confirmation_event, cand_id, updated_message, is_unverified: false)
    expect_message(:flash_notice, updated_message) unless updated_message.nil?

    expect(page).to have_css "form[action='/mass_edit_candidates_event_update/#{confirmation_event.id}']"

    expect(page).to have_css("input[type='submit'][value='#{I18n.t('views.common.update')}']", count: 2)

    expect(page).to have_css("input[id='top-update'][type='submit'][value='#{I18n.t('views.common.update')}']")

    expect(page).to have_css 'input[type=checkbox][id=verified][value="1"]'
    expect(page).to have_field(I18n.t('views.events.verified'))
    expect(page).to have_field(I18n.t('views.events.completed_date'))

    cand = Candidate.find_by(id: cand_id)
    expect_sorting_candidate_list(
      candidate_events_columns(confirmation_event),
      [cand],
      page,
      confirmation_event
    )

    event_key = confirmation_event.event_key
    expect(cand.get_candidate_event(event_key).completed_date).to eq(Time.zone.today) unless updated_message.nil?
    expect(cand.get_candidate_event(event_key).verified).to be(true) if updated_message && !is_unverified
    expect(cand.get_candidate_event(event_key).verified).to be(false) if is_unverified
  end

  # Expect Pick Confirmation Name
  #
  # === Parameters:
  #
  # * <tt>:cand_id</tt>
  # * <tt>:path_str</tt>
  # * <tt>:dev_path</tt>
  # * <tt>:update_id</tt>
  # * <tt>:is_verify</tt>
  # * <tt>:values</tt>
  #
  def expect_pick_confirmation_name_form(cand_id, path_str, dev_path, update_id, is_verify, values = {})
    with_values = values[:saint_name].present?

    saint_name = with_values ? SAINT_NAME : values[:saint_name]

    expect_messages(values[:expected_messages]) unless values[:expected_messages].nil?

    cand = Candidate.find(cand_id)
    expect_heading(cand, dev_path.empty?, PickConfirmationName.event_key)

    expect(page).to have_selector("form[id=edit_candidate][action=\"/#{dev_path}#{path_str}.#{cand_id}\"]")

    expect_field(I18n.t('activerecord.attributes.pick_confirmation_name.saint_name'), with_values ? saint_name : '')

    expect(page).to have_button(update_id)
    expect(page).to have_button(I18n.t('views.common.un_verify'), count: 2) if is_verify
    expect_download_button(Event::Document::CONFIRMATION_NAME, cand_id, dev_path)
  end

  # checks tables have the right size
  #
  # === Parameters:
  #
  # * <tt>:cand</tt>
  # * <tt>:is_dev</tt>
  # * <tt>:event_key</tt>
  #
  def expect_heading(cand, is_dev, event_key)
    # This is testing _two_column_signed_event.html.erb & _two_column_event.html.erb
    first = cand.candidate_sheet.first_name
    last = cand.candidate_sheet.last_name

    i18n_event_name = Candidate.i18n_event_name(event_key)
    if is_dev
      expect(page).to have_selector('h2[id=heading]', text: I18n.t('views.events.heading',
                                                                   event_name: i18n_event_name,
                                                                   first: first, last: last))
    else
      expect(page).to have_selector('h2[id=heading]', text: i18n_event_name.to_s)
      expect(page).not_to have_selector('h2[id=heading]', text: I18n.t('views.events.heading',
                                                                       event_name: i18n_event_name,
                                                                       first: first, last: last))
    end
  end

  # Expect Christian Ministry Form
  #
  # === Parameters:
  #
  # * <tt>:cand_id</tt>
  # * <tt>:path_str</tt>
  # * <tt>:dev_path</tt>
  # * <tt>:update_id</tt>
  # * <tt>:is_verify</tt>
  # * <tt>:values</tt>
  #
  def expect_christian_ministry_form(cand_id, path_str, dev_path, update_id, is_verify, values = {})
    with_values = values[:what_service].present?
    with_values ||= values[:where_service].present?
    with_values ||= values[:when_service].present?
    with_values ||= values[:helped_me].present?

    expect_messages(values[:expected_messages]) unless values[:expected_meessages].nil?

    cand = Candidate.find(cand_id)
    expect_heading(cand, dev_path.empty?, ChristianMinistry.event_key)

    expect(page).to have_selector("form[id=edit_candidate][action=\"/#{dev_path}#{path_str}.#{cand_id}\"]")

    expect_field(I18n.t('activerecord.attributes.christian_ministry.what_service'), with_values ? values[:what_service] : '')
    expect_field(I18n.t('activerecord.attributes.christian_ministry.where_service'), with_values ? values[:where_service] : '')
    expect_field(I18n.t('activerecord.attributes.christian_ministry.when_service'), with_values ? values[:when_service] : '')
    expect_field(I18n.t('activerecord.attributes.christian_ministry.helped_me'), with_values ? values[:helped_me] : '')

    expect(page).to have_button(update_id)
    expect(page).to have_button(I18n.t('views.common.un_verify'), count: 2) if is_verify
    expect_download_button(Event::Document::CHRISTIAN_MINISTRY, cand_id, dev_path)
  end

  private

  def common_non_event_columns
    [
      [I18n.t('label.candidate_event.select'), false, '', expect_select_checkbox],
      [I18n.t('views.nav.status'), false, '',
       ->(cand_id, rendered, td_index) { expect(rendered).to have_css "td[id='tr#{cand_id}_td#{td_index}']" }],
      # [I18n.t('label.candidate_event.select'), false, '', expect_select_checkbox],
      [I18n.t('activerecord.attributes.candidate_sheet.last_name'), true, %i[candidate_sheet last_name]],
      [I18n.t('activerecord.attributes.candidate_sheet.first_name'), true, %i[candidate_sheet first_name]],
      [I18n.t('activerecord.attributes.candidate_sheet.attending'), true, %i[candidate_sheet attending]]
    ]
  end

  # Returns Array of Event info
  #
  # === Returns:
  #
  # * <tt>:Array</tt> Event name, boolean?, lambda
  #
  def common_event_columns
    [
      [I18n.t('events.candidate_covenant_agreement'), true, '', expect_event(Candidate.covenant_agreement_event_key)],
      [I18n.t('events.candidate_information_sheet'), true, '', expect_event(CandidateSheet.event_key)],
      [I18n.t('events.baptismal_certificate'), true, '', expect_event(BaptismalCertificate.event_key)],
      [I18n.t('events.sponsor_covenant'), true, '', expect_event(SponsorCovenant.event_key)],
      [I18n.t('events.sponsor_eligibility'), true, '', expect_event(SponsorEligibility.event_key)],
      [I18n.t('events.confirmation_name'), true, '', expect_event(PickConfirmationName.event_key)],
      [I18n.t('events.christian_ministry'), true, '', expect_event(ChristianMinistry.event_key)],
      [I18n.t('events.retreat_verification'), true, '', expect_event(RetreatVerification.event_key)],
      [I18n.t('events.parent_meeting'), true, '', expect_event(Candidate.parent_meeting_event_key)]
    ]
  end

  def event_key_to_path_verify(event_key, candidate_id)
    setup_event_key_to_path_verify if @event_key_to_path_verify_offset.nil?
    event_key_entry = Candidate.event_keys[event_key]
    raise "unknown_event_key: #{event_key}" if event_key_entry.nil?

    event_key_entry[@event_key_to_path_verify_offset].call(candidate_id)
  end

  def setup_event_key_to_path_verify
    entries = {}
    entries[BaptismalCertificate.event_key] = lambda do |candidate_id|
      event_with_picture_verify_path(candidate_id, Event::Route::BAPTISMAL_CERTIFICATE)
    end
    entries[CandidateSheet.event_key] = ->(candidate_id) { candidate_sheet_verify_path(candidate_id) }
    entries[ChristianMinistry.event_key] = ->(candidate_id) { christian_ministry_verify_path(candidate_id) }
    entries[PickConfirmationName.event_key] = ->(candidate_id) { pick_confirmation_name_verify_path(candidate_id) }
    entries[RetreatVerification.event_key] = lambda do |candidate_id|
      event_with_picture_verify_path(candidate_id, Event::Route::RETREAT_VERIFICATION)
    end
    entries[SponsorCovenant.event_key] = lambda do |candidate_id|
      event_with_picture_verify_path(candidate_id, Event::Route::SPONSOR_COVENANT)
    end
    entries[SponsorEligibility.event_key] = lambda do |candidate_id|
      event_with_picture_verify_path(candidate_id, Event::Route::SPONSOR_ELIGIBILITY)
    end
    entries[Candidate.parent_meeting_event_key] = lambda do |candidate_id|
      anchor = "event_id_#{ConfirmationEvent.find_by(event_key: Candidate.parent_meeting_event_key).id}"
      event_candidate_path(candidate_id, anchor: anchor)
    end
    entries[Candidate.covenant_agreement_event_key] = ->(candidate_id) { sign_agreement_verify_path(candidate_id) }

    @event_key_to_path_verify_offset = Candidate.add_new_event_key_entry(entries)
  end

  def setup_event_key_to_path
    entries = {}
    entries[BaptismalCertificate.event_key] = lambda do |candidate_id|
      event_with_picture_path(candidate_id, Event::Route::BAPTISMAL_CERTIFICATE)
    end
    entries[CandidateSheet.event_key] = ->(candidate_id) { candidate_sheet_path(candidate_id) }
    entries[ChristianMinistry.event_key] = ->(candidate_id) { christian_ministry_path(candidate_id) }
    entries[PickConfirmationName.event_key] = ->(candidate_id) { pick_confirmation_name_path(candidate_id) }
    entries[RetreatVerification.event_key] = lambda do |candidate_id|
      event_with_picture_path(candidate_id, Event::Route::RETREAT_VERIFICATION)
    end
    entries[SponsorCovenant.event_key] = lambda do |candidate_id|
      event_with_picture_path(candidate_id, Event::Route::SPONSOR_COVENANT)
    end
    entries[SponsorEligibility.event_key] = lambda do |candidate_id|
      event_with_picture_path(candidate_id, Event::Route::SPONSOR_ELIGIBILITY)
    end
    entries[Candidate.parent_meeting_event_key] = lambda do |candidate_id|
      anchor = "event_id_#{ConfirmationEvent.find_by(event_key: Candidate.parent_meeting_event_key).id}"
      event_candidate_path(candidate_id, anchor: anchor)
    end
    entries[Candidate.covenant_agreement_event_key] = ->(candidate_id) { sign_agreement_path(candidate_id) }

    @event_key_to_path_offset = Candidate.add_new_event_key_entry(entries)
  end

  def event_key_to_path(event_key, candidate_id)
    setup_event_key_to_path if @event_key_to_path_offset.nil?
    event_key_entry = Candidate.event_keys[event_key]
    raise "unknown_event_key: #{event_key}" if event_key_entry.nil?

    event_key_entry[@event_key_to_path_offset].call(candidate_id)
  end
end
