# frozen_string_literal: true

# rubocop:disable RSpec/ContextWording
shared_context 'candidate_sheet_html_erb' do
  # rubocop:enable RSpec/ContextWording
  include ViewsHelpers
  before do
    FactoryBot.create(:visitor)
    AppFactory.add_confirmation_events
    @candidate = Candidate.find_by(account_name: @candidate.account_name)

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

  it 'candidate logs in, selects candidate sheet, attempts to save an invalid sheet' do
    cand = Candidate.find(@candidate.id)
    cand.candidate_sheet.candidate_email = 'm'
    cand.save(validate: false)

    visit @path

    expect_candidate_sheet_form(@candidate.id, @path_str, @dev, @update_id, @is_verify)

    click_button(@update_id)

    # rubocop:disable Layout/LineLength
    expect_candidate_sheet_form(@candidate.id, @path_str, @dev, @update_id, @is_verify,
                                expected_messages: [
                                  [:flash_notice, @updated_failed_verification],
                                  [:error_explanation, [I18n.t('messages.error.missing_attribute', err_count: 1),
                                                        I18n.t('errors.format',
                                                               attribute: I18n.t('activerecord.attributes.candidate_sheet.candidate_email'),
                                                               message: I18n.t('messages.error.invalid_email', email: 'm'))]]
                                ])
    # rubocop:enable Layout/LineLength
  end

  # rubocop:disable Layout/LineLength
  it 'candidate logs in, selects candidate sheet, has filled out candidate sheet previously puts in invalid email, attempts to save an invalid sheet' do
    # rubocop:enable Layout/LineLength
    visit @path
    fill_in(I18n.t('activerecord.attributes.candidate_sheet.candidate_email'), with: 'mm')

    click_button(@update_id)
    # rubocop:disable Layout/LineLength
    expect_candidate_sheet_form(@candidate.id, @path_str, @dev, @update_id, @is_verify,
                                expected_messages: [
                                  [:flash_notice, @updated_failed_verification],
                                  [:error_explanation, [I18n.t('messages.error.missing_attribute', err_count: 1),
                                                        I18n.t('errors.format',
                                                               attribute: I18n.t('activerecord.attributes.candidate_sheet.candidate_email'),
                                                               message: I18n.t('messages.error.invalid_email', email: 'm'))]]
                                ])
    # rubocop:enable Layout/LineLength
  end

  it 'candidate fills out candidate sheet' do
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
                                  expected_messages: [[:flash_notice, @updated_message]])

    end

    expect_db(1, 0) # make sure DB does not increase in size.
  end

  it 'admin un-verifies a verified candidate sheet event' do
    expect(@is_verify == true || @is_verify == false).to be(true)

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
                                        candidate.id, expected_msg, is_unverified: true)
    else
      expect_candidate_sheet_form(@candidate.id, @path_str, @dev, @update_id, @is_verify)
    end

    expect(candidate.get_candidate_event(event_key).completed_date).to eq(today)
    expect(candidate.get_candidate_event(event_key).verified).to eq(!@is_verify)
  end

  private

  def expect_candidate_sheet_form(cand_id, path_str, dev_path, update_id, is_verify, values = {})
    cand = Candidate.find(cand_id)
    expect_messages(values[:expected_messages]) unless values[:expected_messages].nil?

    expect_heading(cand, dev_path.empty?, CandidateSheet.event_key)

    expect(page).to have_selector("form[id=edit_candidate][action=\"/#{dev_path}#{path_str}.#{cand_id}\"]")

    candidate_sheet = cand.candidate_sheet
    expect(page).to have_field(I18n.t('activerecord.attributes.candidate_sheet.first_name'),
                               with: candidate_sheet.first_name, type: 'text')
    expect(page).to have_field(I18n.t('activerecord.attributes.candidate_sheet.middle_name'),
                               with: candidate_sheet.middle_name, type: 'text')
    expect(page).to have_field(I18n.t('activerecord.attributes.candidate_sheet.last_name'),
                               with: candidate_sheet.last_name, type: 'text')

    expect(page).to have_field(I18n.t('activerecord.attributes.candidate_sheet.grade'),
                               with: candidate_sheet.grade, type: 'number')
    expect(page).to have_field(I18n.t('activerecord.attributes.candidate_sheet.program_year'),
                               with: candidate_sheet.program_year, type: 'number')

    expect(page).to have_field(I18n.t('activerecord.attributes.candidate_sheet.candidate_email'),
                               with: candidate_sheet.candidate_email, type: 'email')
    expect(page).to have_field(I18n.t('activerecord.attributes.candidate_sheet.parent_email_1'),
                               with: candidate_sheet.parent_email_1, type: 'email')
    expect(page).to have_field(I18n.t('activerecord.attributes.candidate_sheet.parent_email_2'),
                               with: candidate_sheet.parent_email_2, type: 'email')

    expect(page).to have_button(update_id)
    expect(page).to have_button(I18n.t('views.common.un_verify'), count: 2) if is_verify
  end

  private

  def fill_in_form(candidate_sheet)
    fill_in(I18n.t('activerecord.attributes.candidate_sheet.first_name'), with: candidate_sheet.first_name)
    fill_in(I18n.t('activerecord.attributes.candidate_sheet.middle_name'), with: candidate_sheet.middle_name)
    fill_in(I18n.t('activerecord.attributes.candidate_sheet.last_name'), with: candidate_sheet.last_name)

    fill_in(I18n.t('activerecord.attributes.candidate_sheet.candidate_email'), with: candidate_sheet.candidate_email)
    fill_in(I18n.t('activerecord.attributes.candidate_sheet.parent_email_1'), with: candidate_sheet.parent_email_1)
    fill_in(I18n.t('activerecord.attributes.candidate_sheet.parent_email_2'), with: candidate_sheet.parent_email_2)
  end
end
