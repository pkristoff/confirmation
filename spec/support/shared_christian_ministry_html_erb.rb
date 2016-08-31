WHAT_SERVICE = '9am mass'
WHERE_SERVICE = 'Over there'
WHEN_SERVICE = 'Yesterday'
HELPED_ME = 'look better'


shared_context 'christian_ministry_html_erb' do

  before(:each) do
    event_with_picture_setup(nil, Event::Route::CHRISTIAN_MINISTRY)

  end

  scenario 'admin logs in and selects a candidate, nothing else showing' do
    update_christian_ministry(false)
    visit @path
    expect_form_layout(@candidate, false)
  end

  scenario 'admin logs in and selects a candidate, fills in template and no picture' do
    AppFactory.add_confirmation_event(I18n.t('events.christian_ministry'))
    update_christian_ministry(false)
    visit @path

    fill_in_form(false)
    click_button I18n.t('views.common.update')

    expect_message(:flash_notice, I18n.t('messages.updated'))
    candidate = Candidate.find(@candidate.id)
    expect(candidate.christian_ministry.what_service).to eq(WHAT_SERVICE)
    expect(candidate.christian_ministry.where_service).to eq(WHERE_SERVICE)
    expect(candidate.christian_ministry.when_service).to eq(WHEN_SERVICE)
    expect(candidate.christian_ministry.helped_me).to eq(HELPED_ME)
    expect(candidate.christian_ministry.signed).to eq(true)
    expect(candidate.christian_ministry.christian_ministry_filename).to eq(nil)

    expect(candidate.get_candidate_event(I18n.t('events.christian_ministry')).completed_date).to eq(Date.today)

    visit @path
    candidate = Candidate.find(@candidate.id)
    expect_form_layout(candidate, true)
  end

  scenario 'admin logs in and selects a candidate, fills in template and picture' do
    AppFactory.add_confirmation_event(I18n.t('events.christian_ministry'))
    update_christian_ministry(false)
    visit @path
    fill_in_form(true)
    click_button I18n.t('views.common.update')

    expect_message(:flash_notice, I18n.t('messages.updated'))
    candidate = Candidate.find(@candidate.id)
    expect(candidate.christian_ministry.what_service).to eq(WHAT_SERVICE)
    expect(candidate.christian_ministry.where_service).to eq(WHERE_SERVICE)
    expect(candidate.christian_ministry.when_service).to eq(WHEN_SERVICE)
    expect(candidate.christian_ministry.helped_me).to eq(HELPED_ME)
    expect(candidate.christian_ministry.signed).to eq(true)
    expect(candidate.christian_ministry.christian_ministry_filename).to eq('actions.png')

    expect(candidate.get_candidate_event(I18n.t('events.christian_ministry')).completed_date).to eq(Date.today)

    visit @path
    candidate = Candidate.find(@candidate.id)
    expect_form_layout(candidate, true)
  end

  scenario 'admin logs in and selects a candidate, adds picture, updates, updates - everything is saved' do
    AppFactory.add_confirmation_event(I18n.t('events.christian_ministry'))
    candidate = Candidate.find(@candidate.id)
    candidate.christian_ministry.signed=false
    candidate.save
    update_christian_ministry(false)
    visit @path

    attach_file('Christian ministry picture', 'spec/fixtures/actions.png')
    click_button I18n.t('views.common.update')

    expect_message(:flash_notice, I18n.t('messages.updated'))
    candidate = Candidate.find(@candidate.id)
    expect(candidate.christian_ministry.what_service).to eq('')
    expect(candidate.christian_ministry.where_service).to eq('')
    expect(candidate.christian_ministry.when_service).to eq('')
    expect(candidate.christian_ministry.helped_me).to eq('')
    expect(candidate.christian_ministry.signed).to eq(false)
    expect(candidate.christian_ministry.christian_ministry_filename).to eq('actions.png')

    expect(candidate.get_candidate_event(I18n.t('events.christian_ministry')).completed_date).to eq(Date.today)

    visit @path
    candidate = Candidate.find(@candidate.id)
    expect_form_layout(candidate, false)

  end

  scenario 'admin logs in and selects a candidate, fills in template, except saint_name' do

    update_christian_ministry(false)
    visit @path
    fill_in_form(false)
    fill_in('What service', with: nil)
    click_button I18n.t('views.common.update')

    expect_message(:error_explanation, '4 errors prohibited saving: Christian ministry filename can\'t be blank Christian ministry content type can\'t be blank Christian ministry file contents can\'t be blank What service can\'t be blank')
    candidate = Candidate.find(@candidate.id)
    expect_form_layout(candidate, true, '')
  end

  def expect_form_layout(candidate, with_values, what_service=WHAT_SERVICE)

    expect(page).to have_selector("form[id=edit_candidate][action=\"/#{@dev}event_with_picture/#{@candidate.id}/christian_ministry\"]")

    expect_field('Christian ministry picture', nil)

    expect_field('What service', with_values ? what_service : '')
    expect_field('Where service', with_values ? WHERE_SERVICE : '')
    expect_field('When service', with_values ? WHEN_SERVICE : '')
    expect_field('Helped me', with_values ? HELPED_ME : '')

    expect(page).to have_button(I18n.t('views.common.update'))
    expect(page).to have_button(I18n.t('views.common.download'))
  end

  def expect_field (label, value)
    if value.nil? or value === ''
      expect(page).to have_field(label)
    else
      expect(page).to have_field(label, with: value)
    end
  end

  def fill_in_form(christian_ministry_attach_file=true)
    fill_in('What service', with: WHAT_SERVICE)
    fill_in('Where service', with: WHERE_SERVICE)
    fill_in('When service', with: WHEN_SERVICE)
    fill_in('Helped me', with: HELPED_ME)
    check('Signed')
    if christian_ministry_attach_file
      attach_file('Christian ministry picture', 'spec/fixtures/actions.png')
    end
  end

  def get_img_src_selector
    "img[src=\"/#{@dev}event_with_picture_image/#{@candidate.id}/christian_ministry\"]"
  end

  def update_christian_ministry(with_values)
    if with_values
      @candidate.christian_ministry.what_service=WHAT_SERVICE
      @candidate.save
    end
  end
end