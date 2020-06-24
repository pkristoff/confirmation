# frozen_string_literal: true

shared_context 'candidate_sheet_html_erb' do
  include ViewsHelpers
  before(:each) do
    AppFactory.add_confirmation_events
    @candidate = Candidate.find_by(account_name: @candidate.account_name)

    page.driver.header 'Accept-Language', locale
    I18n.locale = locale

    cand_name = 'Sophia Agusta'
    if @is_verify
      @updated_message = I18n.t('messages.updated_verified', cand_name: cand_name)
      @updated_failed_verification = I18n.t('messages.updated_not_verified', cand_name: cand_name)
    else
      @updated_message = I18n.t('messages.updated', cand_name: cand_name)
      @updated_failed_verification = I18n.t('messages.updated', cand_name: cand_name)
    end
  end

  scenario 'candidate logs in, selects candidate sheet, attempts to save an invalid sheet' do
    cand = Candidate.find(@candidate.id)
    cand.candidate_sheet.candidate_email = 'm'
    cand.save(validate: false)

    visit @path

    expect_candidate_sheet_form(@candidate.id, @path_str, @dev, @update_id, @is_verify)

    click_button(@update_id)

    expect_candidate_sheet_form(@candidate.id, @path_str, @dev, @update_id, @is_verify,
                                expect_messages: [
                                  [:flash_notice, @updated_failed_verification],
                                  [:error_explanation, [I18n.t('messages.error.missing_attribute', err_count: 1),
                                                        "Candidate email #{I18n.t('messages.error.invalid_email', email: 'm')}"]]
                                ])
  end

  # rubocop:disable Layout/LineLength
  scenario 'candidate logs in, selects candidate sheet, has filled out candidate sheet previsouly puts in invalid email, attempts to save an invalid sheet' do
    # rubocop:enable Layout/LineLength
    visit @path
    fill_in(I18n.t('label.candidate_sheet.candidate_email'), with: 'mm')

    click_button(@update_id)
    expect_candidate_sheet_form(@candidate.id, @path_str, @dev, @update_id, @is_verify,
                                expect_messages: [
                                  [:flash_notice, @updated_failed_verification],
                                  [:error_explanation, [I18n.t('messages.error.missing_attribute', err_count: 1),
                                                        "Candidate email #{I18n.t('messages.error.invalid_email', email: 'mm')}"]]
                                ])
  end

  scenario 'candidate fills out candidate sheet' do
    expect_db(1, 0)

    visit @path

    candidate_sheet = @candidate.candidate_sheet
    candidate_sheet.candidate_email = 'can.didate@email.com'

    fill_in_form(candidate_sheet)

    click_button(@update_id)

    if @admin_verified

      candidate = Candidate.find(@candidate.id)
      expect_mass_edit_candidates_event(ConfirmationEvent.find_by(event_key: CandidateSheet.event_key),
                                        candidate.id, @updated_message)

    else

      expect_candidate_sheet_form(@candidate.id, @path_str, @dev, @update_id, @is_verify,
                                  expect_messages: [[:flash_notice, @updated_message]])

    end

    expect_db(1, 0) # make sure DB does not increase in size.
  end

  scenario 'admin un-verifies a verified candidate sheet event' do
    expect(@is_verify == true || @is_verify == false).to eq(true)

    event_key = CandidateSheet.event_key
    today = Time.zone.today
    @candidate.get_candidate_event(event_key).completed_date = today
    @candidate.get_candidate_event(event_key).verified = true
    @candidate.save

    visit @path

    expect_candidate_sheet_form(@candidate.id, @path_str, @dev, @update_id, @is_verify)

    expect(page).to have_button(I18n.t('views.common.un_verify'), count: 2) if @is_verify
    click_button 'bottom-unverify' if @is_verify

    candidate = Candidate.find(@candidate.id)
    if @is_verify
      expected_msg = I18n.t('messages.updated_unverified',
                            cand_name: "#{candidate.candidate_sheet.first_name} #{candidate.candidate_sheet.last_name}")
      expect_mass_edit_candidates_event(ConfirmationEvent.find_by(event_key: event_key),
                                        candidate.id, expected_msg, true)
    else
      expect_candidate_sheet_form(@candidate.id, @path_str, @dev, @update_id, @is_verify)
    end

    expect(candidate.get_candidate_event(event_key).completed_date).to eq(today)
    expect(candidate.get_candidate_event(event_key).verified).to eq(!@is_verify)
  end

  def expect_candidate_sheet_form(cand_id, path_str, dev_path, update_id, is_verify, values = {})
    cand = Candidate.find(cand_id)
    expect_messages(values[:expect_messages]) unless values[:expect_messages].nil?

    expect_heading(cand, dev_path.empty?, CandidateSheet.event_key)

    expect(page).to have_selector("form[id=edit_candidate][action=\"/#{dev_path}#{path_str}.#{cand_id}\"]")

    candidate_sheet = cand.candidate_sheet
    expect(page).to have_field(I18n.t('label.candidate_sheet.first_name'), with: candidate_sheet.first_name, type: 'text')
    expect(page).to have_field(I18n.t('label.candidate_sheet.middle_name'),
                               with: candidate_sheet.middle_name, type: 'text')
    expect(page).to have_field(I18n.t('label.candidate_sheet.last_name'), with: candidate_sheet.last_name, type: 'text')

    expect(page).to have_field(I18n.t('label.candidate_sheet.address.street_1'),
                               with: candidate_sheet.address.street_1, type: 'text')
    expect(page).to have_field(I18n.t('label.candidate_sheet.address.street_2'),
                               with: candidate_sheet.address.street_2, type: 'text')
    expect(page).to have_field(I18n.t('label.candidate_sheet.address.city'), with: candidate_sheet.address.city, type: 'text')
    expect(page).to have_field(I18n.t('label.candidate_sheet.address.state'), with: candidate_sheet.address.state, type: 'text')
    expect(page).to have_field(I18n.t('label.candidate_sheet.address.zip_code'),
                               with: candidate_sheet.address.zip_code, type: 'text')

    expect(page).to have_field(I18n.t('label.candidate_sheet.grade'), with: candidate_sheet.grade, type: 'number')
    expect(page).to have_field(I18n.t('label.candidate_sheet.program_year'), with: candidate_sheet.program_year, type: 'number')

    expect(page).to have_field(I18n.t('label.candidate_sheet.candidate_email'),
                               with: candidate_sheet.candidate_email, type: 'email')
    expect(page).to have_field(I18n.t('label.candidate_sheet.parent_email_1'),
                               with: candidate_sheet.parent_email_1, type: 'email')
    expect(page).to have_field(I18n.t('label.candidate_sheet.parent_email_2'),
                               with: candidate_sheet.parent_email_2, type: 'email')

    expect(page).to have_button(update_id)
    expect(page).to have_button(I18n.t('views.common.un_verify'), count: 2) if is_verify
  end

  def fill_in_form(candidate_sheet)
    fill_in(I18n.t('label.candidate_sheet.first_name'), with: candidate_sheet.first_name)
    fill_in(I18n.t('label.candidate_sheet.middle_name'), with: candidate_sheet.middle_name)
    fill_in(I18n.t('label.candidate_sheet.last_name'), with: candidate_sheet.last_name)

    address = candidate_sheet.address
    fill_in(I18n.t('label.candidate_sheet.address.street_1'), with: address.street_1)
    fill_in(I18n.t('label.candidate_sheet.address.street_2'), with: address.street_2)
    fill_in(I18n.t('label.candidate_sheet.address.city'), with: address.city)
    fill_in(I18n.t('label.candidate_sheet.address.state'), with: address.state)
    fill_in(I18n.t('label.candidate_sheet.address.zip_code'), with: address.zip_code)

    fill_in(I18n.t('label.candidate_sheet.candidate_email'), with: candidate_sheet.candidate_email)
    fill_in(I18n.t('label.candidate_sheet.parent_email_1'), with: candidate_sheet.parent_email_1)
    fill_in(I18n.t('label.candidate_sheet.parent_email_2'), with: candidate_sheet.parent_email_2)
  end
end
