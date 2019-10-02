# frozen_string_literal: true

SPONSOR_NAME = 'George Sponsor'
SPONSOR_CHURCH = 'St. George'

SPONSOR_COVENANT_EVENT = I18n.t('events.sponsor_covenant')

UPDATED_MESSAGE = I18n.t('messages.updated', cand_name: 'Sophia Agusta')

ATTENDS_STMM_LABEL_I18N = 'label.sponsor_covenant.sponsor_attends_home_parish'
COVENANT_PICTURE_LABEL = I18n.t('label.sponsor_covenant.sponsor_covenant_picture')
ELEGIBILITY_PICTURE_LABEL = I18n.t('label.sponsor_covenant.sponsor_eligibility_picture')
SPONSOR_CHURCH_LABEL = I18n.t('label.sponsor_covenant.sponsor_church')
SPONSOR_NAME_LABEL = I18n.t('label.sponsor_covenant.sponsor_name')

shared_context 'sponsor_covenant_html_erb' do
  include ViewsHelpers
  before(:each) do
    event_with_picture_setup(Event::Route::SPONSOR_COVENANT, @is_verify)
    AppFactory.add_confirmation_events
  end

  scenario 'admin logs in and selects a candidate, checks sponsor_attends_home_parish, nothing else showing' do
    @candidate.sponsor_covenant.sponsor_attends_home_parish = true
    @candidate.save
    update_sponsor_covenant(false)
    visit @path

    expect_sponsor_covenant_form(@candidate.id, @dev, @path_str, @is_verify)
  end

  scenario 'admin logs in and selects a candidate, unchecks sponsor_attends_home_parish, rest showing' do
    @candidate.sponsor_covenant.sponsor_attends_home_parish = false
    @candidate.save
    update_sponsor_covenant(true)
    visit @path

    expect_sponsor_covenant_form(@candidate.id, @dev, @path_str, @is_verify)
  end

  scenario 'admin logs in and selects a candidate, unchecks sponsor_attends_home_parish, fills in template' do
    @candidate.sponsor_covenant.sponsor_attends_home_parish = false
    @candidate.save
    update_sponsor_covenant(false)
    expect(@candidate.sponsor_covenant.sponsor_attends_home_parish).to eq(false)

    visit @path
    fill_in_form(true, true)
    click_button @update_id

    expect_sponsor_covenant_form(@candidate.id, @dev, @path_str, @is_verify, expect_messages: [[:flash_notice, @updated_message]])
    candidate = Candidate.find(@candidate.id)
    expect(candidate.sponsor_covenant.sponsor_name).to eq(SPONSOR_NAME)
    expect(candidate.sponsor_covenant.sponsor_church).to eq(SPONSOR_CHURCH)
  end

  scenario 'admin logs in and selects a candidate, unchecks sponsor_attends_home_parish, fills in template then changes mind she was baptized at stmm' do
    @candidate.sponsor_covenant.sponsor_attends_home_parish = false
    @candidate.save
    update_sponsor_covenant(false)

    expect_db(1, 8, 0)

    visit @path
    fill_in_form
    click_button @update_id

    expect_sponsor_covenant_form(@candidate.id, @dev, @path_str, @is_verify, expect_messages: [[:flash_notice, @updated_message]])

    visit @path
    check(ATTENDS_STMM_LABEL)
    click_button @update_id

    expect_sponsor_covenant_form(@candidate.id, @dev, @path_str, @is_verify, expect_messages: [[:flash_notice, @updated_message]])

    candidate = Candidate.find(@candidate.id)
    expect(candidate.sponsor_covenant.sponsor_attends_home_parish).to eq(true)
    expect(candidate.sponsor_covenant).not_to eq(nil)

    expect_db(1, 8, 2) # make sure DB does not increase in size.
  end

  scenario 'admin logs in and selects a candidate, unchecks sponsor_attends_home_parish, adds picture, updates, adds rest of valid data, updates - everything is saved' do
    @candidate.sponsor_covenant.sponsor_attends_home_parish = false
    @candidate.save
    update_sponsor_covenant(false)

    expect_db(1, 8, 0)

    visit @path

    attach_file(COVENANT_PICTURE_LABEL, 'spec/fixtures/actions.png')
    attach_file(ELEGIBILITY_PICTURE_LABEL, 'spec/fixtures/actions.png')
    click_button @update_id

    candidate_db = Candidate.find(@candidate.id)
    expect_sponsor_covenant_form(candidate_db.id, @dev, @path_str, @is_verify,
                                 expect_messages: [[:flash_notice, @updated_failed_verification],
                                                   [:error_explanation, ['Your changes were saved!! 2 empty fields need to be filled in on the form to be verified:', 'Sponsor name can\'t be blank', 'Sponsor church can\'t be blank']]])

    expect(candidate_db.sponsor_covenant).not_to eq(nil)
    expect(candidate_db.sponsor_covenant.sponsor_attends_home_parish).to eq(false)
    expect(candidate_db.sponsor_covenant.scanned_eligibility.filename).to eq('actions.png')
    expect(candidate_db.sponsor_covenant.scanned_covenant.filename).to eq('actions.png')
    expect(candidate_db.sponsor_covenant.sponsor_name).to eq('')
    expect(candidate_db.sponsor_covenant.sponsor_church).to eq('')

    fill_in_form(false) # no picture
    click_button @update_id

    candidate_db_update = Candidate.find(@candidate.id)
    expect_sponsor_covenant_form(candidate_db_update.id, @dev, @path_str, @is_verify, expect_messages: [[:flash_notice, @updated_message]])
    expect(candidate_db_update.sponsor_covenant).not_to eq(nil)
    expect(candidate_db_update.sponsor_covenant.sponsor_attends_home_parish).to eq(false)
    expect(candidate_db_update.sponsor_covenant.scanned_eligibility.filename).to eq('Baptismal Certificate.png')
    expect(candidate_db_update.sponsor_covenant.scanned_covenant.filename).to eq('actions.png')
    expect(candidate_db_update.sponsor_covenant.sponsor_name).to eq(SPONSOR_NAME)
    expect(candidate_db_update.sponsor_covenant.sponsor_church).to eq(SPONSOR_CHURCH)

    event = candidate_db_update.get_candidate_event(SPONSOR_COVENANT_EVENT)
    # this errors periodically
    expect(event.candidate).to eq(candidate_db_update)
    expect(event.completed_date).to eq(Time.zone.today)
    expect(event.verified).to eq(false)

    visit @path
    candidate_db_visit = Candidate.find(@candidate.id)
    expect_sponsor_covenant_form(candidate_db_visit.id, @dev, @path_str, @is_verify)

    expect_db(1, 8, 2) # make sure DB does not increase in size.
  end

  scenario 'admin logs in and selects a candidate, unchecks sponsor_attends_home_parish, adds non-picture data, updates, adds picture, updates - everything is saved' do
    @candidate.sponsor_covenant.sponsor_attends_home_parish = false
    @candidate.save
    update_sponsor_covenant(false)
    visit @path

    fill_in_form(false, true) # no picture
    click_button @update_id

    expect_sponsor_covenant_form(@candidate.id, @dev, @path_str, @is_verify,
                                 expect_messages: [[:flash_notice, @updated_failed_verification],
                                                   [:error_explanation, ['Your changes were saved!! 1 empty field needs to be filled in on the form to be verified:', 'Scanned sponsor covenant form can\'t be blank']]])

    expect(page).to have_selector("img[src=\"/#{@dev}upload_sponsor_eligibility_image.#{@candidate.id}\"]")
    expect(page).not_to have_selector(img_src_selector)

    attach_file(COVENANT_PICTURE_LABEL, 'spec/fixtures/actions.png')
    click_button @update_id

    expect_sponsor_covenant_form(@candidate.id, @dev, @path_str, @is_verify,
                                 expect_messages: [[:flash_notice, @updated_message]])
    candidate = Candidate.find(@candidate.id)
    expect(candidate.sponsor_covenant.sponsor_attends_home_parish).to eq(false)
    expect(candidate.sponsor_covenant).not_to eq(nil)
    expect(candidate.sponsor_covenant.scanned_eligibility.filename).not_to eq(nil)

    visit @path
    candidate = Candidate.find(@candidate.id)
    expect_sponsor_covenant_form(candidate.id, @dev, @path_str, @is_verify)
  end

  scenario 'admin logs in and selects a candidate, unchecks sponsor_attends_home_parish, fills in template, except sponsor_name' do
    @candidate.sponsor_covenant.sponsor_attends_home_parish = false
    @candidate.save
    update_sponsor_covenant(false)
    visit @path
    fill_in_form

    fill_in(SPONSOR_NAME_LABEL, with: nil)
    click_button @update_id

    expect(page).to have_selector(img_src_selector)
    candidate = Candidate.find(@candidate.id)
    expect_sponsor_covenant_form(candidate.id, @dev, @path_str, @is_verify,
                                 expect_messages: [[:flash_notice, @updated_failed_verification],
                                                   [:error_explanation, ['Your changes were saved!! 1 empty field needs to be filled in on the form to be verified:', 'Sponsor name can\'t be blank']]],
                                 sponsor_name: '')
  end

  def expect_sponsor_covenant_form(cand_id, dev_path, path_str, is_verify, values = { sponsor_name: SPONSOR_NAME })
    expect_messages(values[:expect_messages]) unless values[:expect_messages].nil?

    cand = Candidate.find(cand_id)
    expect_heading(cand, dev_path.empty?, I18n.t('events.sponsor_covenant'))

    visibility = cand.sponsor_covenant.sponsor_attends_home_parish ? 'hide-div' : 'show-div'
    expect(page).to have_selector("form[id=edit_candidate][action=\"/#{dev_path}#{path_str}/#{cand_id}/sponsor_covenant\"]")
    expect(page).to have_selector("div[id=sponsor-covenant-top][class=\"#{visibility}\"]")

    if cand.sponsor_covenant.sponsor_attends_home_parish
      expect(page).to have_checked_field(I18n.t(ATTENDS_STMM_LABEL_I18N, home_parish: Visitor.home_parish))
    else
      expect(page).not_to have_checked_field(I18n.t(ATTENDS_STMM_LABEL_I18N, home_parish: Visitor.home_parish))
    end

    expect_field(COVENANT_PICTURE_LABEL, nil)

    expect_field(SPONSOR_NAME_LABEL, cand.sponsor_covenant.sponsor_attends_home_parish ? nil : values[:sponsor_name])

    expect(page).to have_button(@update_id)

    remove_count = if cand.sponsor_covenant.scanned_covenant.nil?
                     0 if cand.sponsor_covenant.scanned_eligibility.nil?
                     1 unless cand.sponsor_covenant.scanned_eligibility.nil?
                   else
                     1 if cand.sponsor_covenant.scanned_eligibility.nil?
                     2 unless cand.sponsor_covenant.scanned_eligibility.nil?
                   end
    expect_remove_button('candidate_sponsor_covenant_attributes_remove_sponsor_covenant_picture', 'sponsor_covenant_picture') unless cand.sponsor_covenant.scanned_covenant.nil?
    expect_remove_button('candidate_sponsor_covenant_attributes_remove_sponsor_eligibility_picture', 'sponsor_eligibility_picture') unless cand.sponsor_covenant.scanned_eligibility.nil?
    expect(page).to have_button(I18n.t('views.common.remove_image'), count: remove_count)
    expect(page).to have_button(I18n.t('views.common.replace_image'), count: remove_count)
    expect(page).to have_button(I18n.t('views.common.un_verify'), count: 2) if is_verify
    expect_download_button(Event::Route::SPONSOR_COVENANT, cand_id, dev_path)
  end

  def fill_in_form(covenant_attach_file = true, eligibility_attach_file = true)
    fill_in(SPONSOR_NAME_LABEL, with: SPONSOR_NAME)
    fill_in(SPONSOR_CHURCH_LABEL, with: SPONSOR_CHURCH)
    attach_file(COVENANT_PICTURE_LABEL, 'spec/fixtures/actions.png') if covenant_attach_file
    attach_file(ELEGIBILITY_PICTURE_LABEL, 'spec/fixtures/Baptismal Certificate.png') if eligibility_attach_file
  end

  def img_src_selector
    "img[src=\"/#{@dev}event_with_picture_image/#{@candidate.id}/sponsor_covenant\"]"
  end

  def update_sponsor_covenant(with_values)
    @candidate.sponsor_covenant.sponsor_name = SPONSOR_NAME if with_values
    @candidate.save if with_values
  end
end
