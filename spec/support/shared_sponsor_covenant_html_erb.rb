# frozen_string_literal: true

SPONSOR_COVENANT_EVENT = SponsorCovenant.event_key

shared_context 'sponsor_covenant_html_erb' do
  include ViewsHelpers
  before(:each) do
    event_with_picture_setup(Event::Route::SPONSOR_COVENANT, { is_verify: @is_verify })
    AppFactory.add_confirmation_events

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

  scenario 'admin logs in and selects a candidate, checks sponsor_attends_home_parish, nothing else showing' do
    @candidate.sponsor_eligibility.sponsor_attends_home_parish = true
    @candidate.save!

    visit @path

    expect_sponsor_covenant_form(@candidate.id, @dev, @path_str, @is_verify)
  end

  scenario 'admin logs in and selects a candidate, unchecks sponsor_attends_home_parish, rest showing' do
    @candidate.sponsor_covenant.sponsor_name = SPONSOR_NAME
    @candidate.sponsor_eligibility.sponsor_attends_home_parish = false
    @candidate.save!
    visit @path

    expect_sponsor_covenant_form(@candidate.id, @dev, @path_str, @is_verify)
  end

  scenario 'admin logs in and selects a candidate, unchecks sponsor_attends_home_parish, fills in template' do
    @candidate.sponsor_eligibility.sponsor_attends_home_parish = false
    @candidate.save!

    expect(@candidate.sponsor_eligibility.sponsor_attends_home_parish).to eq(false)

    visit @path
    fill_in_form({ covenant_attach_file: true })
    click_button @update_id

    expect_sponsor_covenant_form(@candidate.id, @dev, @path_str, @is_verify,
                                 expect_messages: [[:flash_notice, @updated_message]])
    candidate = Candidate.find(@candidate.id)
    expect(candidate.sponsor_covenant.sponsor_name).to eq(SPONSOR_NAME)
  end

  scenario 'admin logs in and selects a candidate, fills in template saves changes sponsor_name' do
    @candidate.sponsor_eligibility.sponsor_attends_home_parish = false
    @candidate.save!

    expect_db(1, 0)

    visit @path
    fill_in_form
    click_button @update_id

    expect_sponsor_covenant_form(@candidate.id,
                                 @dev,
                                 @path_str,
                                 @is_verify,
                                 expect_messages: [[:flash_notice, @updated_message]])

    visit @path
    fill_in(I18n.t('label.sponsor_covenant.sponsor_name'), with: 'xxx')
    click_button @update_id

    expect_sponsor_covenant_form(@candidate.id,
                                 @dev,
                                 @path_str,
                                 @is_verify,
                                 expect_messages: [[:flash_notice, @updated_message]])

    candidate = Candidate.find(@candidate.id)
    expect(candidate.sponsor_covenant.sponsor_name).to eq('xxx')
    expect(candidate.sponsor_covenant).not_to eq(nil)

    expect_db(1, 1) # make sure DB does not increase in size.
  end

  # rubocop:disable Layout/LineLength
  scenario 'admin logs in and selects a candidate, unchecks sponsor_attends_home_parish, adds picture, updates, adds rest of valid data, updates - everything is saved' do
    @candidate.sponsor_eligibility.sponsor_attends_home_parish = false
    @candidate.save!

    expect_db(1, 0)

    visit @path

    attach_file(I18n.t('label.sponsor_covenant.sponsor_covenant_picture'), 'spec/fixtures/actions.png')
    click_button @update_id

    candidate_db = Candidate.find(@candidate.id)
    expect_sponsor_covenant_form(candidate_db.id, @dev, @path_str, @is_verify,
                                 expect_messages: [[:flash_notice, @updated_failed_verification],
                                                   [:error_explanation, [I18n.t('messages.error.missing_attribute'),
                                                                         "Sponsor name #{I18n.t('errors.messages.blank')}"]]])

    expect(candidate_db.sponsor_covenant).not_to eq(nil)
    expect(candidate_db.sponsor_covenant.scanned_covenant.filename).to eq('actions.png')
    expect(candidate_db.sponsor_covenant.sponsor_name).to eq('')

    fill_in_form({ covenant_attach_file: false }) # no picture
    click_button @update_id

    candidate_db_update = Candidate.find(@candidate.id)
    expect_sponsor_covenant_form(candidate_db_update.id, @dev, @path_str, @is_verify,
                                 expect_messages: [[:flash_notice, @updated_message]])
    expect(candidate_db_update.sponsor_covenant).not_to eq(nil)
    expect(candidate_db_update.sponsor_covenant.scanned_covenant.filename).to eq('actions.png')
    expect(candidate_db_update.sponsor_covenant.sponsor_name).to eq(SPONSOR_NAME)

    event = candidate_db_update.get_candidate_event(SPONSOR_COVENANT_EVENT)
    # this errors periodically
    expect(event.candidate).to eq(candidate_db_update)
    expect(event.completed_date).to eq(Time.zone.today)
    expect(event.verified).to eq(true)

    visit @path
    candidate_db_visit = Candidate.find(@candidate.id)
    expect_sponsor_covenant_form(candidate_db_visit.id, @dev, @path_str, @is_verify)

    expect_db(1, 1) # make sure DB does not increase in size.
  end
  # rubocop:enable Layout/LineLength

  # rubocop:disable Layout/LineLength
  scenario 'admin logs in and selects a candidate, unchecks sponsor_attends_home_parish, adds non-picture data, updates, adds picture, updates - everything is saved' do
    @candidate.sponsor_eligibility.sponsor_attends_home_parish = false
    @candidate.save!

    visit @path

    fill_in_form({ covenant_attach_file: false }) # no picture
    click_button @update_id

    expect_sponsor_covenant_form(@candidate.id, @dev, @path_str, @is_verify,
                                 expect_messages: [[:flash_notice, @updated_failed_verification],
                                                   [:error_explanation, [I18n.t('messages.error.missing_attribute', err_count: 1),
                                                                         "Scanned sponsor covenant form #{I18n.t('errors.messages.blank')}"]]])

    expect(page).not_to have_selector(img_src_selector)

    attach_file(I18n.t('label.sponsor_covenant.sponsor_covenant_picture'), 'spec/fixtures/actions.png')
    click_button @update_id

    expect_sponsor_covenant_form(@candidate.id, @dev, @path_str, @is_verify,
                                 expect_messages: [[:flash_notice, @updated_message]])
    candidate = Candidate.find(@candidate.id)
    expect(candidate.sponsor_covenant).not_to eq(nil)

    visit @path
    candidate = Candidate.find(@candidate.id)
    expect_sponsor_covenant_form(candidate.id, @dev, @path_str, @is_verify)
  end
  # rubocop:enable Layout/LineLength

  # rubocop:disable Layout/LineLength
  scenario 'admin logs in and selects a candidate, unchecks sponsor_attends_home_parish, fills in template, except sponsor_name' do
    @candidate.sponsor_eligibility.sponsor_attends_home_parish = false
    @candidate.save!

    visit @path
    fill_in_form

    fill_in(I18n.t('label.sponsor_covenant.sponsor_name'), with: nil)
    click_button @update_id

    expect(page).to have_selector(img_src_selector)
    candidate = Candidate.find(@candidate.id)
    expect_sponsor_covenant_form(candidate.id, @dev, @path_str, @is_verify,
                                 expect_messages: [[:flash_notice, @updated_failed_verification],
                                                   [:error_explanation, [I18n.t('messages.error.missing_attribute', err_count: 1),
                                                                         "Sponsor name #{I18n.t('errors.messages.blank')}"]]],
                                 sponsor_name: '')
  end
  # rubocop:enable Layout/LineLength

  private

  def expect_sponsor_covenant_form(cand_id, dev_path, path_str, is_verify, values = { sponsor_name: SPONSOR_NAME })
    # rubocop:disable Layout/LineLength
    expect_messages(values[:expect_messages]) unless values[:expect_messages].nil?

    cand = Candidate.find(cand_id)
    expect_heading(cand, dev_path.empty?, SponsorCovenant.event_key)

    expect(page).to have_selector("form[id=edit_candidate][action=\"/#{dev_path}#{path_str}/#{cand_id}/sponsor_covenant\"]")

    expect_field(I18n.t('label.sponsor_covenant.sponsor_covenant_picture'), nil)

    expect(page).to have_button(@update_id)
    remove_count = 0 if cand.sponsor_covenant.scanned_covenant.nil?
    remove_count = 1 unless cand.sponsor_covenant.scanned_covenant.nil?
    expect_remove_button('candidate_sponsor_covenant_attributes_remove_sponsor_covenant_picture', 'sponsor_covenant_picture') unless cand.sponsor_covenant.scanned_covenant.nil?
    expect(page).to have_button(I18n.t('views.common.remove_image'), count: remove_count)
    expect(page).to have_button(I18n.t('views.common.replace_image'), count: remove_count)
    expect(page).to have_button(I18n.t('views.common.un_verify'), count: 1) if is_verify
    expect_download_button(Event::Route::SPONSOR_COVENANT, cand_id, dev_path)
    # rubocop:enable Layout/LineLength
  end

  def fill_in_form(covenant_attach_file: true)
    fill_in(I18n.t('label.sponsor_covenant.sponsor_name'), with: SPONSOR_NAME)
    attach_file(I18n.t('label.sponsor_covenant.sponsor_covenant_picture'), 'spec/fixtures/actions.png') if covenant_attach_file
  end

  def img_src_selector
    "img[src=\"/#{@dev}event_with_picture_image/#{@candidate.id}/sponsor_covenant\"]"
  end
end
