# frozen_string_literal: true

SPONSOR_NAME = 'George Sponsor'
SPONSOR_CHURCH = 'St. George'

SPONSOR_ELIGIBILITY_EVENT = SponsorEligibility.event_key

shared_context 'sponsor_eligibility_html_erb' do
  include ViewsHelpers
  before(:each) do
    event_with_picture_setup(Event::Route::SPONSOR_ELIGIBILITY, { is_verify: @is_verify })
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
    @candidate.save
    update_sponsor_eligibility(false)
    visit @path

    expect_sponsor_eligibility_form(@candidate.id, @dev, @path_str, @is_verify)
  end

  scenario 'admin logs in and selects a candidate, checks sponsor_attends_home_parish, Sponsor name is blank' do
    @candidate.sponsor_eligibility.sponsor_attends_home_parish = false
    @candidate.save
    update_sponsor_eligibility(false)
    visit @path

    fill_in(I18n.t('label.sponsor_eligibility.sponsor_name'), with: '')
    fill_in(I18n.t('label.sponsor_eligibility.sponsor_church'), with: SPONSOR_CHURCH)
    attach_file(I18n.t('label.sponsor_eligibility.sponsor_eligibility_picture'), 'spec/fixtures/Baptismal Certificate.png')
    click_button @update_id

    expect_sponsor_eligibility_form(
      @candidate.id, @dev, @path_str, @is_verify,
      expected_messages: [[:flash_notice, @updated_failed_verification],
                          [:error_explanation, [I18n.t('messages.error.missing_attribute',
                                                       err_count: 1),
                                                "Sponsor name #{I18n.t('errors.messages.blank')}"]]]
    )
  end

  scenario 'admin logs in and selects a candidate, unchecks sponsor_attends_home_parish, rest showing' do
    @candidate.sponsor_eligibility.sponsor_attends_home_parish = false
    @candidate.save
    update_sponsor_eligibility(true)
    visit @path

    expect_sponsor_eligibility_form(@candidate.id, @dev, @path_str, @is_verify)
  end

  scenario 'admin logs in and selects a candidate, unchecks sponsor_attends_home_parish, fills in template' do
    @candidate.sponsor_eligibility.sponsor_attends_home_parish = false
    @candidate.save
    update_sponsor_eligibility(false)
    expect(@candidate.sponsor_eligibility.sponsor_attends_home_parish).to eq(false)

    visit @path
    fill_in_form({ eligibility_attach_file: true })
    click_button @update_id

    expect_sponsor_eligibility_form(@candidate.id, @dev, @path_str, @is_verify,
                                    expected_messages: [[:flash_notice, @updated_message]])
    candidate = Candidate.find(@candidate.id)
    expect(candidate.sponsor_covenant.sponsor_name).to eq(SPONSOR_NAME)
    expect(candidate.sponsor_eligibility.sponsor_church).to eq(SPONSOR_CHURCH)
  end

  # rubocop:disable Layout/LineLength
  scenario 'admin logs in and selects a candidate, unchecks sponsor_attends_home_parish, fills in template then changes mind she was baptized at stmm' do
    @candidate.sponsor_eligibility.sponsor_attends_home_parish = false
    @candidate.save
    update_sponsor_eligibility(false)

    expect_db(1, 0)

    visit @path
    fill_in_form
    click_button @update_id

    expect_sponsor_eligibility_form(@candidate.id, @dev, @path_str, @is_verify, expected_messages: [[:flash_notice, @updated_message]])

    visit @path
    check(I18n.t('label.sponsor_eligibility.sponsor_attends_home_parish', home_parish: Visitor.home_parish))
    click_button @update_id

    expect_sponsor_eligibility_form(@candidate.id, @dev, @path_str, @is_verify, expected_messages: [[:flash_notice, @updated_message]])

    candidate = Candidate.find(@candidate.id)
    expect(candidate.sponsor_eligibility.sponsor_attends_home_parish).to eq(true)
    expect(candidate.sponsor_eligibility).not_to eq(nil)

    expect_db(1, 1) # , 2) # make sure DB does not increase in size.
  end
  # rubocop:enable Layout/LineLength

  # rubocop:disable Layout/LineLength
  scenario 'admin logs in and selects a candidate, unchecks sponsor_attends_home_parish, adds picture, updates, adds rest of valid data, updates - everything is saved' do
    @candidate.sponsor_eligibility.sponsor_attends_home_parish = false
    @candidate.save
    update_sponsor_eligibility(true)

    expect_db(1, 0)

    visit @path

    attach_file(I18n.t('label.sponsor_eligibility.sponsor_eligibility_picture'), 'spec/fixtures/actions.png')
    click_button @update_id

    candidate_db = Candidate.find(@candidate.id)
    expect_sponsor_eligibility_form(candidate_db.id, @dev, @path_str, @is_verify,
                                    expected_messages: [[:flash_notice, @updated_failed_verification],
                                                        [:error_explanation, [I18n.t('messages.error.missing_attribute', err_count: 1),
                                                                              "Sponsor church #{I18n.t('errors.messages.blank')}"]]])

    expect(candidate_db.sponsor_eligibility).not_to eq(nil)
    expect(candidate_db.sponsor_eligibility.sponsor_attends_home_parish).to eq(false)
    expect(candidate_db.sponsor_eligibility.scanned_eligibility.filename).to eq('actions.png')
    expect(candidate_db.sponsor_covenant.sponsor_name).to eq(SPONSOR_NAME)
    expect(candidate_db.sponsor_eligibility.sponsor_church).to eq('')

    fill_in_form({ eligibility_attach_file: false }) # no picture
    click_button @update_id

    candidate_db_update = Candidate.find(@candidate.id)
    expect_sponsor_eligibility_form(candidate_db_update.id, @dev, @path_str, @is_verify,
                                    expected_messages: [[:flash_notice, @updated_message]])
    expect(candidate_db_update.sponsor_eligibility).not_to eq(nil)
    expect(candidate_db_update.sponsor_eligibility.sponsor_attends_home_parish).to eq(false)
    expect(candidate_db_update.sponsor_eligibility.scanned_eligibility.filename).to eq('actions.png')
    expect(candidate_db_update.sponsor_covenant.sponsor_name).to eq(SPONSOR_NAME)
    expect(candidate_db_update.sponsor_eligibility.sponsor_church).to eq(SPONSOR_CHURCH)

    event = candidate_db_update.get_candidate_event(SPONSOR_ELIGIBILITY_EVENT)
    # this errors periodically
    expect(event.candidate).to eq(candidate_db_update)
    expect(event.completed_date).to eq(Time.zone.today)
    expect(event.verified).to eq(false)

    visit @path
    candidate_db_visit = Candidate.find(@candidate.id)
    expect_sponsor_eligibility_form(candidate_db_visit.id, @dev, @path_str, @is_verify)

    expect_db(1, 1) # make sure DB does not increase in size.
  end
  # rubocop:enable Layout/LineLength

  # rubocop:disable Layout/LineLength
  scenario 'admin logs in and selects a candidate, unchecks sponsor_attends_home_parish, adds non-picture data, updates, adds picture, updates - everything is saved' do
    @candidate.sponsor_eligibility.sponsor_attends_home_parish = false
    @candidate.save
    update_sponsor_eligibility(false)
    visit @path

    fill_in_form({ eligibility_attach_file: false }) # no picture
    click_button @update_id

    expect_sponsor_eligibility_form(@candidate.id, @dev, @path_str, @is_verify,
                                    expected_messages: [[:flash_notice, @updated_failed_verification],
                                                        [:error_explanation, [I18n.t('messages.error.missing_attribute', err_count: 1),
                                                                              "Scanned sponsor eligibility form #{I18n.t('errors.messages.blank')}"]]])

    expect(page).not_to have_selector("img[src=\"/#{@dev}upload_sponsor_eligibility_image.#{@candidate.id}\"]")
    expect(page).not_to have_selector(img_src_selector)

    attach_file(I18n.t('label.sponsor_eligibility.sponsor_eligibility_picture'), 'spec/fixtures/actions.png')
    click_button @update_id

    expect_sponsor_eligibility_form(@candidate.id, @dev, @path_str, @is_verify,
                                    expected_messages: [[:flash_notice, @updated_message]])
    candidate = Candidate.find(@candidate.id)
    expect(candidate.sponsor_eligibility.sponsor_attends_home_parish).to eq(false)
    expect(candidate.sponsor_eligibility).not_to eq(nil)
    expect(candidate.sponsor_eligibility.scanned_eligibility.filename).not_to eq(nil)

    visit @path
    candidate = Candidate.find(@candidate.id)
    expect_sponsor_eligibility_form(candidate.id, @dev, @path_str, @is_verify)
  end
  # rubocop:enable Layout/LineLength

  scenario 'admin logs in and selects a candidate, unchecks sponsor_attends_home_parish, fills in template' do
    @candidate.sponsor_eligibility.sponsor_attends_home_parish = false
    @candidate.save
    update_sponsor_eligibility(false)
    visit @path
    fill_in_form

    attach_file(I18n.t('label.sponsor_eligibility.sponsor_eligibility_picture'), 'spec/fixtures/actions.png')
    fill_in(I18n.t('label.sponsor_eligibility.sponsor_name'), with: 'george')
    click_button @update_id

    candidate = Candidate.find(@candidate.id)
    expect_sponsor_eligibility_form(candidate.id,
                                    @dev, @path_str, @is_verify,
                                    expected_messages: [[:flash_notice, @updated_message]],
                                    sponsor_name: '')
    expect(page).to have_selector(img_src_selector)
  end

  private

  def expect_sponsor_eligibility_form(cand_id, dev_path, path_str, is_verify, values = { sponsor_name: SPONSOR_NAME })
    # rubocop:disable Layout/LineLength
    expect_messages(values[:expected_messages]) unless values[:expected_messages].nil?

    cand = Candidate.find(cand_id)
    expect_heading(cand, dev_path.empty?, SponsorEligibility.event_key)

    visibility = cand.sponsor_eligibility.sponsor_attends_home_parish ? 'hide-div' : 'show-div'
    expect(page).to have_selector("form[id=edit_candidate][action=\"/#{dev_path}#{path_str}/#{cand_id}/sponsor_eligibility\"]")
    expect(page).to have_selector("div[id=sponsor-eligibility-top][class=\"#{visibility}\"]")

    if cand.sponsor_eligibility.sponsor_attends_home_parish
      expect(page).to have_checked_field(I18n.t('label.sponsor_eligibility.sponsor_attends_home_parish', home_parish: Visitor.home_parish))
    else
      expect(page).not_to have_checked_field(I18n.t('label.sponsor_eligibility.sponsor_attends_home_parish', home_parish: Visitor.home_parish))
    end

    expect_field(I18n.t('label.sponsor_eligibility.sponsor_eligibility_picture'), nil)

    expect_field(I18n.t('label.sponsor_eligibility.sponsor_name'), cand.sponsor_eligibility.sponsor_attends_home_parish ? nil : values[:sponsor_name])

    expect(page).to have_button(@update_id)

    expect_remove_button('candidate_sponsor_eligibility_attributes_remove_sponsor_eligibility_picture', 'sponsor_eligibility_picture') unless cand.sponsor_eligibility.scanned_eligibility.nil?
    expect(page).to have_button(I18n.t('views.common.remove_image'), count: 1)
    expect(page).to have_button(I18n.t('views.common.replace_image'), count: 1)
    expect(page).to have_button(I18n.t('views.common.un_verify'), count: 1) if is_verify
    expect_download_button(Event::Route::SPONSOR_ELIGIBILITY, cand_id, dev_path)
    # rubocop:enable Layout/LineLength
  end

  def fill_in_form(eligibility_attach_file: true)
    fill_in(I18n.t('label.sponsor_eligibility.sponsor_name'), with: SPONSOR_NAME)
    fill_in(I18n.t('label.sponsor_eligibility.sponsor_church'), with: SPONSOR_CHURCH)
    filename = 'spec/fixtures/Baptismal Certificate.png'
    attach_file(I18n.t('label.sponsor_eligibility.sponsor_eligibility_picture'), filename) if eligibility_attach_file
  end

  def img_src_selector
    "img[src=\"/#{@dev}event_with_picture_image/#{@candidate.id}/sponsor_eligibility\"]"
  end

  def update_sponsor_eligibility(with_values)
    @candidate.sponsor_covenant.sponsor_name = SPONSOR_NAME if with_values
    @candidate.save if with_values
  end
end
