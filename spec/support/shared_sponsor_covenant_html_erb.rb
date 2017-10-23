SPONSOR_NAME = 'George Sponsor'
SPONSOR_CHURCH = 'St. George'

SPONSOR_COVENANT_EVENT = I18n.t('events.sponsor_covenant')

UPDATED_MESSAGE = I18n.t('messages.updated')

ATTENDS_STMM_LABEL = I18n.t('label.sponsor_covenant.sponsor_attends_stmm')
COVENANT_PICTURE_LABEL = I18n.t('label.sponsor_covenant.sponsor_covenant_picture')
ELEGIBILITY_PICTURE_LABEL = I18n.t('label.sponsor_covenant.sponsor_eligibility_picture')
SPONSOR_CHURCH_LABEL = I18n.t('label.sponsor_covenant.sponsor_church')
SPONSOR_NAME_LABEL = I18n.t('label.sponsor_covenant.sponsor_name')

shared_context 'sponsor_covenant_html_erb' do

  before(:each) do
    event_with_picture_setup(Event::Route::SPONSOR_COVENANT)
    AppFactory.add_confirmation_events
  end

  scenario 'admin logs in and selects a candidate, checks sponsor_attends_stmm, nothing else showing' do
    @candidate.sponsor_covenant.sponsor_attends_stmm = true
    @candidate.save
    update_sponsor_covenant(false)
    visit @path
    expect_form_layout(@candidate)
  end

  scenario 'admin logs in and selects a candidate, unchecks sponsor_attends_stmm, rest showing' do
    @candidate.sponsor_covenant.sponsor_attends_stmm = false
    @candidate.save
    update_sponsor_covenant(true)
    visit @path
    expect_form_layout(@candidate)
  end

  scenario 'admin logs in and selects a candidate, unchecks sponsor_attends_stmm, fills in template' do
    @candidate.sponsor_covenant.sponsor_attends_stmm = false
    @candidate.save
    update_sponsor_covenant(false)
    expect(@candidate.sponsor_covenant.sponsor_attends_stmm).to eq(false)
    visit @path
    fill_in_form(true, true)
    click_button 'top-update'

    expect_message(:flash_notice, 'Updated')
    candidate = Candidate.find(@candidate.id)
    expect(candidate.sponsor_covenant.sponsor_name).to eq(SPONSOR_NAME)
    expect(candidate.sponsor_covenant.sponsor_church).to eq(SPONSOR_CHURCH)
  end

  scenario 'admin logs in and selects a candidate, unchecks sponsor_attends_stmm, fills in template then changes mind she was baptized at stmm' do
    @candidate.sponsor_covenant.sponsor_attends_stmm = false
    @candidate.save
    update_sponsor_covenant(false)

    expect_db(1, 9, 0)

    visit @path
    fill_in_form
    click_button 'top-update'

    visit @path
    check(ATTENDS_STMM_LABEL)
    click_button 'top-update'

    expect_message(:flash_notice, UPDATED_MESSAGE)
    candidate = Candidate.find(@candidate.id)
    expect(candidate.sponsor_covenant.sponsor_attends_stmm).to eq(true)
    expect(candidate.sponsor_covenant).not_to eq(nil)

    expect_db(1, 9, 2)  #make sure DB does not increase in size.
  end

  scenario 'admin logs in and selects a candidate, unchecks sponsor_attends_stmm, adds picture, updates, adds rest of valid data, updates - everything is saved' do
    @candidate.sponsor_covenant.sponsor_attends_stmm = false
    @candidate.save
    update_sponsor_covenant(false)

    expect_db(1, 9, 0)

    visit @path

    attach_file(COVENANT_PICTURE_LABEL, 'spec/fixtures/actions.png')
    attach_file(ELEGIBILITY_PICTURE_LABEL, 'spec/fixtures/actions.png')
    click_button 'top-update'

    candidate_db = Candidate.find(@candidate.id)
    expect_message(:error_explanation, ['2 empty fields need to be filled in', 'Sponsor name can\'t be blank', 'Sponsor church can\'t be blank'])
    expect(candidate_db.sponsor_covenant).not_to eq(nil)
    expect(candidate_db.sponsor_covenant.sponsor_attends_stmm).to eq(false)
    expect(candidate_db.sponsor_covenant.scanned_eligibility.filename).to eq('actions.png')
    expect(candidate_db.sponsor_covenant.scanned_covenant.filename).to eq('actions.png')
    expect(candidate_db.sponsor_covenant.sponsor_name).to eq('')
    expect(candidate_db.sponsor_covenant.sponsor_church).to eq('')
    fill_in_form(false) # no picture
    click_button 'top-update'

    expect_message(:flash_notice, UPDATED_MESSAGE)
    candidate_db_update = Candidate.find(@candidate.id)
    expect(candidate_db_update.sponsor_covenant).not_to eq(nil)
    expect(candidate_db_update.sponsor_covenant.sponsor_attends_stmm).to eq(false)
    expect(candidate_db_update.sponsor_covenant.scanned_eligibility.filename).to eq('Baptismal Certificate.png')
    expect(candidate_db_update.sponsor_covenant.scanned_covenant.filename).to eq('actions.png')
    expect(candidate_db_update.sponsor_covenant.sponsor_name).to eq(SPONSOR_NAME)
    expect(candidate_db_update.sponsor_covenant.sponsor_church).to eq(SPONSOR_CHURCH)

    event = candidate_db_update.get_candidate_event(SPONSOR_COVENANT_EVENT)
    # this errors periodically
    expect(event.candidate).to eq(candidate_db_update)
    expect(event.completed_date).to eq(Date.today)
    expect(event.verified).to eq(false)

    visit @path
    candidate_db_visit = Candidate.find(@candidate.id)
    expect_form_layout(candidate_db_visit)

    expect_db(1, 9, 2)  #make sure DB does not increase in size.

  end

  scenario 'admin logs in and selects a candidate, unchecks sponsor_attends_stmm, adds non-picture data, updates, adds picture, updates - everything is saved' do
    @candidate.sponsor_covenant.sponsor_attends_stmm = false
    @candidate.save
    update_sponsor_covenant(false)
    visit @path

    fill_in_form(false, true) # no picture
    click_button 'top-update'
    expect_message(:error_explanation, ['1 empty field need to be filled in', 'Sponsor eligibility form can\'t be blank', 'Sponsor eligibility content type can\'t be blank', 'Sponsor eligibility file contents can\'t be blank'])
puts page.body
    expect(page).to have_selector("img[src=\"/#{@dev}upload_sponsor_eligibility_image.#{@candidate.id}\"]")
    expect(page).not_to have_selector(get_img_src_selector)

    attach_file(COVENANT_PICTURE_LABEL, 'spec/fixtures/actions.png')
    click_button 'top-update'

    expect_message(:flash_notice, 'Updated')
    candidate = Candidate.find(@candidate.id)
    expect(candidate.sponsor_covenant.sponsor_attends_stmm).to eq(false)
    expect(candidate.sponsor_covenant).not_to eq(nil)
    expect(candidate.sponsor_covenant.scanned_eligibility.filename).not_to eq(nil)

    visit @path
    candidate = Candidate.find(@candidate.id)
    expect_form_layout(candidate)

  end

  scenario 'admin logs in and selects a candidate, unchecks sponsor_attends_stmm, fills in template, except sponsor_name' do
    @candidate.sponsor_covenant.sponsor_attends_stmm = false
    @candidate.save
    update_sponsor_covenant(false)
    visit @path
    fill_in_form
    fill_in('Sponsor name', with: nil)
    click_button 'top-update'

    expect_message(:error_explanation, '1 empty field need to be filled in: Sponsor name can\'t be blank')
    expect(page).to have_selector(get_img_src_selector)
    candidate = Candidate.find(@candidate.id)
    expect_form_layout(candidate, '')
  end

  def expect_form_layout(candidate, sponsor_name=SPONSOR_NAME)
    visibility = candidate.sponsor_covenant.sponsor_attends_stmm ? 'hide-div' : 'show-div'
    expect(page).to have_selector("form[id=edit_candidate][action=\"/#{@dev}event_with_picture/#{@candidate.id}/sponsor_covenant\"]")
    expect(page).to have_selector("div[id=sponsor-covenant-top][class=\"#{visibility}\"]")

    if candidate.sponsor_covenant.sponsor_attends_stmm
      expect(page).to have_checked_field(ATTENDS_STMM_LABEL)
    else
      expect(page).not_to have_checked_field(ATTENDS_STMM_LABEL)
    end

    expect_field(COVENANT_PICTURE_LABEL, nil)

    expect_field(SPONSOR_NAME_LABEL, candidate.sponsor_covenant.sponsor_attends_stmm ? nil : sponsor_name)

    expect(page).to have_button('top-update')
    expect_download_button(Event::Route::SPONSOR_COVENANT)
  end

  def expect_field (label, value)
    if value.nil? or value === ''
      expect(page).to have_field(label)
    else
      expect(page).to have_field(label, with: value)
    end
  end

  def fill_in_form(covenant_attach_file=true, eligibility_attach_file=true)
    fill_in(SPONSOR_NAME_LABEL, with: SPONSOR_NAME)
    fill_in(SPONSOR_CHURCH_LABEL, with: SPONSOR_CHURCH)
    if covenant_attach_file
      attach_file(COVENANT_PICTURE_LABEL, 'spec/fixtures/actions.png')
    end
    if eligibility_attach_file
      attach_file(ELEGIBILITY_PICTURE_LABEL, 'spec/fixtures/Baptismal Certificate.png')
    end
  end

  def get_img_src_selector
    "img[src=\"/#{@dev}event_with_picture_image/#{@candidate.id}/sponsor_covenant\"]"
  end

  def update_sponsor_covenant(with_values)
    if with_values
      @candidate.sponsor_covenant.sponsor_name=SPONSOR_NAME
      @candidate.save
    end
  end
end