# frozen_string_literal: true

WHO_HELD_RETREAT = 'George'
WHERE_HELD_RETREAT = 'Over there'
START_DATE = Time.zone.today - 10
END_DATE = Time.zone.today - 5

shared_context 'retreat_verification_html_erb' do
  include ViewsHelpers
  before(:each) do
    FactoryBot.create(:visitor)
    event_with_picture_setup(Event::Route::RETREAT_VERIFICATION, { is_verify: @is_verify })
    AppFactory.add_confirmation_events

    @candidate_event_id = @candidate.get_candidate_event(RetreatVerification.event_key).id
    @cand_id = @candidate.id
    @today = Time.zone.today
    v = Visitor.all.first
    v.home_parish = 'St. Mary Magdalene'
    v.save

    page.driver.header 'Accept-Language', locale
    I18n.locale = locale

    cand_name = 'Sophia Augusta'
    if @is_verify
      @updated_message = I18n.t('messages.updated_verified', cand_name: cand_name)
      @updated_failed_verification = I18n.t('messages.updated_not_verified', cand_name: cand_name)
    else
      @updated_message = I18n.t('messages.updated', cand_name: cand_name)
      @updated_failed_verification = I18n.t('messages.updated', cand_name: cand_name)
    end
  end

  scenario 'admin logs in and selects a candidate, nothing else showing' do
    visit @path
    expect_retreat_verification_form(@cand_id, @dev, @path_str, @is_verify,
                                     who_held_retreat: '',
                                     where_held_retreat: '',
                                     start_date: '',
                                     end_date: '')
  end

  scenario 'admin logs in and selects a candidate, fills in template and no picture' do
    expect_db(1, 0)

    visit @path

    fill_in_form(false)
    click_button @update_id

    candidate = Candidate.find(@cand_id)
    if @is_verify

      expect_mass_edit_candidates_event(ConfirmationEvent.find_by(event_key: RetreatVerification.event_key),
                                        candidate.id, @updated_message)

    else

      expect_retreat_verification_form(@cand_id, @dev, @path_str, @is_verify,
                                       expected_messages: [[:flash_notice, @updated_message]])
    end

    retreat_verification = candidate.retreat_verification
    expect(retreat_verification.retreat_held_at_home_parish).to eq(true)
    expect(retreat_verification.who_held_retreat).to eq(WHO_HELD_RETREAT)
    expect(retreat_verification.where_held_retreat).to eq(WHERE_HELD_RETREAT)
    expect(retreat_verification.start_date).to eq(START_DATE)
    expect(retreat_verification.end_date).to eq(END_DATE)
    expect(retreat_verification.scanned_retreat).to eq(nil)

    expect(CandidateEvent.find(@candidate_event_id).completed_date).to eq(@today)
    expect(CandidateEvent.find(@candidate_event_id).verified).to eq(@is_verify)

    visit @path
    expect_retreat_verification_form(@cand_id, @dev, @path_str, @is_verify)

    expect_db(1, 0) # make sure DB does not increase in size.
  end

  scenario 'admin logs in and selects a candidate, fills in template and picture' do
    expect_db(1, 0)
    visit @path
    fill_in_form(true)
    click_button @update_id

    candidate = Candidate.find(@cand_id)

    # rubocop:disable Layout/LineLength
    if @is_verify

      expect_mass_edit_candidates_event(ConfirmationEvent.find_by(event_key: RetreatVerification.event_key), candidate.id, @updated_message)

    else
      expect_retreat_verification_form(@cand_id, @dev, @path_str, @is_verify, expected_messages: [[:flash_notice, @updated_message]])
    end
    # rubocop:enable Layout/LineLength
    retreat_verification = candidate.retreat_verification
    expect(retreat_verification.who_held_retreat).to eq(WHO_HELD_RETREAT)
    expect(retreat_verification.where_held_retreat).to eq(WHERE_HELD_RETREAT)
    expect(retreat_verification.start_date).to eq(START_DATE)
    expect(retreat_verification.end_date).to eq(END_DATE)
    expect(retreat_verification.scanned_retreat.filename).to eq('actions for spec testing.png')

    expect(CandidateEvent.find(@candidate_event_id).completed_date).to eq(@today)
    expect(CandidateEvent.find(@candidate_event_id).verified).to eq(@is_verify)

    visit @path
    expect_retreat_verification_form(@cand_id, @dev, @path_str, @is_verify)

    expect_db(1, 1) # make sure DB does not increase in size.
  end

  scenario 'admin logs in and selects a candidate, adds picture, updates, updates - everything is saved' do
    expect_db(1, 0)
    candidate = Candidate.find(@cand_id)
    candidate.retreat_verification.retreat_held_at_home_parish = false
    candidate.save
    visit @path

    attach_file(I18n.t('activerecord.attributes.retreat_verification.retreat_verification_picture'),
                'spec/fixtures/actions for spec testing.png')
    click_button @update_id

    # rubocop:disable Layout/LineLength
    expect_retreat_verification_form(@cand_id, @dev, @path_str, @is_verify,
                                     expected_messages: [[:flash_notice, @updated_failed_verification],
                                                         [:error_explanation, [I18n.t('messages.error.missing_attributes', err_count: 4),
                                                                               I18n.t('errors.format_blank',
                                                                                      attribute: I18n.t('activerecord.attributes.retreat_verification.start_date')),
                                                                               I18n.t('errors.format_blank',
                                                                                      attribute: I18n.t('activerecord.attributes.retreat_verification.end_date')),
                                                                               I18n.t('errors.format_blank',
                                                                                      attribute: I18n.t('activerecord.attributes.retreat_verification.who_held_retreat')),
                                                                               I18n.t('errors.format_blank',
                                                                                      attribute: I18n.t('activerecord.attributes.retreat_verification.where_held_retreat'))]]],

                                     who_held_retreat: '',
                                     where_held_retreat: '',
                                     start_date: '',
                                     end_date: '')
    # rubocop:enable Layout/LineLength

    expect(Candidate.find(@cand_id).retreat_verification.scanned_retreat.filename).to eq('actions for spec testing.png')

    expect(CandidateEvent.find(@candidate_event_id).completed_date).to eq(nil)

    visit @path
    expect_retreat_verification_form(@cand_id, @dev, @path_str, @is_verify,
                                     who_held_retreat: '',
                                     where_held_retreat: '',
                                     start_date: '',
                                     end_date: '')

    expect_db(1, 1) # make sure DB does not increase in size.
  end

  scenario 'admin logs in and selects a candidate, fills in form except picture.' do
    # rubocop:disable Layout/LineLength
    candidate = Candidate.find(@cand_id)
    candidate.retreat_verification.retreat_held_at_home_parish = false
    candidate.save

    visit @path

    fill_in_form(false, { check_checkbox: false })
    click_button @update_id

    expect_retreat_verification_form(@cand_id, @dev, @path_str, @is_verify,
                                     expected_messages: [[:flash_notice, @updated_failed_verification],
                                                         [:error_explanation, [I18n.t('messages.error.missing_attribute', err_count: 1),
                                                                               "Scanned retreat verification #{I18n.t('errors.messages.blank')}"]]])
    # rubocop:enable Layout/LineLength
  end

  scenario 'admin logs in and selects a candidate, fills in template, except Who held retreat' do
    candidate = Candidate.find(@cand_id)
    candidate.retreat_verification.retreat_held_at_home_parish = false
    candidate.save
    visit @path

    fill_in_form(true, { check_checkbox: false })

    fill_in(I18n.t('activerecord.attributes.retreat_verification.who_held_retreat', home_parish: Visitor.home_parish), with: nil)
    click_button @update_id

    expected_msg = I18n.t('messages.error.missing_attribute', err_count: 1)
    i18n_string = 'activerecord.attributes.retreat_verification.who_held_retreat'
    expect_retreat_verification_form(@cand_id, @dev, @path_str, @is_verify,
                                     expected_messages: [[:flash_notice, @updated_failed_verification],
                                                         [:error_explanation, [expected_msg,
                                                                               I18n.t('errors.format_blank',
                                                                                      attribute: I18n.t(i18n_string))]]],

                                     who_held_retreat: '')
  end

  scenario 'admin un-verifies a verified retreat verification event' do
    expect(@is_verify == true || @is_verify == false).to eq(true)

    event_key = RetreatVerification.event_key
    candidate = Candidate.find(@cand_id)
    candidate.retreat_verification.retreat_held_at_home_parish = true
    candidate.get_candidate_event(event_key).completed_date = @today
    candidate.get_candidate_event(event_key).verified = true
    candidate.save

    visit @path

    expect_retreat_verification_form(@cand_id, @dev, @path_str, @is_verify,
                                     who_held_retreat: '',
                                     where_held_retreat: '',
                                     start_date: '',
                                     end_date: '')

    expect(page).to have_button(I18n.t('views.common.un_verify'), count: 2) if @is_verify

    click_button 'bottom-unverify' if @is_verify

    candidate = Candidate.find(@candidate.id)
    if @is_verify
      expected_msg = "#{candidate.candidate_sheet.first_name} #{candidate.candidate_sheet.last_name}"
      expect_mass_edit_candidates_event(ConfirmationEvent.find_by(event_key: event_key), candidate.id,
                                        I18n.t('messages.updated_unverified',
                                               cand_name: expected_msg), { is_unverified: true })
    else
      expect_retreat_verification_form(@cand_id, @dev, @path_str, @is_verify,
                                       who_held_retreat: '',
                                       where_held_retreat: '',
                                       start_date: '',
                                       end_date: '')
    end

    expect(candidate.get_candidate_event(event_key).completed_date).to eq(@today)
    expect(candidate.get_candidate_event(event_key).verified).to eq(!@is_verify)
  end

  private

  def expect_retreat_verification_form(cand_id, dev_path, path_str, is_verify,
                                       values = {
                                         who_held_retreat: WHO_HELD_RETREAT,
                                         where_held_retreat: WHERE_HELD_RETREAT,
                                         start_date: START_DATE,
                                         end_date: END_DATE
                                       })
    # rubocop:disable Layout/LineLength
    expect_messages(values[:expected_messages]) unless values[:expected_messages].nil?

    cand = Candidate.find(cand_id)
    expect_heading(cand, dev_path.empty?, RetreatVerification.event_key)

    expect(page).to have_selector("form[id=edit_candidate][action=\"/#{dev_path}#{path_str}/#{cand_id}/retreat_verification\"]")

    expect_field(I18n.t('activerecord.attributes.retreat_verification.retreat_verification_picture'), nil)

    expect_field(I18n.t('activerecord.attributes.retreat_verification.who_held_retreat'), values[:who_held_retreat])
    expect_field(I18n.t('activerecord.attributes.retreat_verification.where_held_retreat'), values[:where_held_retreat])
    expect_field(I18n.t('activerecord.attributes.retreat_verification.start_date'), values[:start_date])
    expect_field(I18n.t('activerecord.attributes.retreat_verification.end_date'), values[:end_date])

    expect_image_upload('retreat_verification', 'retreat_verification_picture', I18n.t('activerecord.attributes.retreat_verification.retreat_verification_picture'))

    expect(page).to have_button(@update_id)
    expect_remove_button('candidate_retreat_verification_attributes_remove_retreat_verification_picture', 'retreat_verification_picture') unless cand.retreat_verification.scanned_retreat.nil?
    # rubocop:enable Layout/LineLength
    expect(page).to have_button(I18n.t('views.common.remove_image'), count: 1)
    expect(page).to have_button(I18n.t('views.common.replace_image'), count: 1)
    expect(page).to have_button(I18n.t('views.common.un_verify'), count: 2) if is_verify
    expect_download_button(Event::Document::RETREAT_VERIFICATION, cand_id, dev_path)
  end

  def fill_in_form(retreat_verification_attach_file, check_checkbox: true)
    # rubocop:disable Layout/LineLength
    check(I18n.t('activerecord.attributes.retreat_verification.retreat_held_at_home_parish', home_parish: Visitor.home_parish)) if check_checkbox
    # rubocop:enable Layout/LineLength
    fill_in(I18n.t('activerecord.attributes.retreat_verification.who_held_retreat'), with: WHO_HELD_RETREAT)
    fill_in(I18n.t('activerecord.attributes.retreat_verification.where_held_retreat'), with: WHERE_HELD_RETREAT)
    fill_in(I18n.t('activerecord.attributes.retreat_verification.start_date'), with: START_DATE)
    fill_in(I18n.t('activerecord.attributes.retreat_verification.end_date'), with: END_DATE)
    label = I18n.t('activerecord.attributes.retreat_verification.retreat_verification_picture')
    attach_file(label, 'spec/fixtures/actions for spec testing.png') if retreat_verification_attach_file
  end

  def img_src_selector
    "img[src=\"/#{@dev}event_with_picture_image/#{@cand_id}/retreat_verification\"]"
  end
end
