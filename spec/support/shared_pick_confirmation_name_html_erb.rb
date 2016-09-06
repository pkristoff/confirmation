SAINT_NAME = 'George Sponsor'
ABOUT_SAINT = 'She was very holy'
WHY_SAINT = 'She looks good'


shared_context 'pick_confirmation_name_html_erb' do

  before(:each) do
    event_with_picture_setup(I18n.t('events.confirmation_name'), Event::Route::CONFIRMATION_NAME)

  end

  scenario 'admin logs in and selects a candidate, nothing else showing' do
    update_pick_confirmation_name(false)
    visit @path
    expect_form_layout(@candidate, false)
  end

  scenario 'admin logs in and selects a candidate, fills in template' do
    update_pick_confirmation_name(false)
    visit @path
    fill_in_form(true)
    click_button 'top-update'

    expect_message(:flash_notice, I18n.t('messages.updated'))
    candidate = Candidate.find(@candidate.id)
    expect(candidate.pick_confirmation_name.saint_name).to eq(SAINT_NAME)
    expect(candidate.pick_confirmation_name.about_saint).to eq(ABOUT_SAINT)
    expect(candidate.pick_confirmation_name.why_saint).to eq(WHY_SAINT)
  end

  scenario 'admin logs in and selects a candidate, adds picture, updates, adds rest of valid data, updates - everything is saved' do
    AppFactory.add_candidate_events(@candidate)
    update_pick_confirmation_name(false)
    visit @path


    attach_file(I18n.t('label.pick_confirmation_name.pick_confirmation_name_picture'), 'spec/fixtures/actions.png')
    click_button 'top-update'

    candidate = Candidate.find(@candidate.id)
    expect(page).to have_selector(get_img_src_selector)
    expect_message(:error_explanation, ['3 empty fields need to be filled in', 'Saint name can\'t be blank', 'About saint can\'t be blank', 'Why saint can\'t be blank'])

    expect(candidate.pick_confirmation_name.pick_confirmation_name_filename).to eq('actions.png')
    expect(candidate.pick_confirmation_name.saint_name).to eq('')
    expect(candidate.pick_confirmation_name.about_saint).to eq('')
    expect(candidate.pick_confirmation_name.why_saint).to eq('')

    fill_in_form(false) # no picture
    click_button 'top-update'

    expect_message(:flash_notice, I18n.t('messages.updated'))
    candidate = Candidate.find(@candidate.id)
    expect(candidate.pick_confirmation_name.pick_confirmation_name_filename).to eq('actions.png')
    expect(candidate.pick_confirmation_name.saint_name).to eq(SAINT_NAME)
    expect(candidate.pick_confirmation_name.about_saint).to eq(ABOUT_SAINT)
    expect(candidate.pick_confirmation_name.why_saint).to eq(WHY_SAINT)

    visit @path
    candidate = Candidate.find(@candidate.id)
    expect_form_layout(candidate, true)

  end

  scenario 'admin logs in and selects a candidate, adds non-picture data, updates, adds picture, updates - everything is saved' do

    update_pick_confirmation_name(false)
    visit @path

    fill_in_form(false) # no picture
    click_button 'top-update'
    expect_message(:error_explanation, ['3 empty fields need to be filled in', 'Pick confirmation name filename can\'t be blank', 'Pick confirmation name content type can\'t be blank', 'Pick confirmation name file contents can\'t be blank'])
    expect(page).not_to have_selector(get_img_src_selector)

    attach_file(I18n.t('label.pick_confirmation_name.pick_confirmation_name_picture'), 'spec/fixtures/actions.png')
    click_button 'top-update'

    expect_message(:flash_notice, 'Updated')
    candidate = Candidate.find(@candidate.id)
    expect(candidate.pick_confirmation_name.pick_confirmation_name_filename).not_to eq(nil)

    visit @path
    candidate = Candidate.find(@candidate.id)
    expect_form_layout(candidate, true)

  end

  scenario 'admin logs in and selects a candidate, fills in template, except saint_name' do

    update_pick_confirmation_name(false)
    visit @path
    fill_in_form
    fill_in('Saint name', with: nil)
    click_button 'top-update'

    expect_message(:error_explanation, '1 empty field need to be filled in: Saint name can\'t be blank')
    candidate = Candidate.find(@candidate.id)
    expect_form_layout(candidate, true, '')
  end

  def expect_form_layout(candidate, with_values, saint_name=SAINT_NAME)

    expect(page).to have_selector("form[id=edit_candidate][action=\"/#{@dev}event_with_picture/#{@candidate.id}/confirmation_name\"]")

    expect_field(I18n.t('label.pick_confirmation_name.pick_confirmation_name_picture'), nil)

    expect_field(I18n.t('label.pick_confirmation_name.saint_name'), with_values ? saint_name : '')
    expect_field(I18n.t('label.pick_confirmation_name.about_saint'), with_values ? ABOUT_SAINT : '')
    expect_field(I18n.t('label.pick_confirmation_name.why_saint'), with_values ? WHY_SAINT : '')

    expect(page).to have_button('top-update')
    expect_download_button(Event::Document::CONFIRMATION_NAME)
  end

  def expect_field (label, value)
    if value.nil? or value === ''
      expect(page).to have_field(label)
    else
      expect(page).to have_field(label, with: value)
    end
  end

  def fill_in_form(pick_confirmation_name_attach_file=true)
    fill_in(I18n.t('label.pick_confirmation_name.saint_name'), with: SAINT_NAME)
    fill_in(I18n.t('label.pick_confirmation_name.about_saint'), with: ABOUT_SAINT)
    fill_in(I18n.t('label.pick_confirmation_name.why_saint'), with: WHY_SAINT)
    if pick_confirmation_name_attach_file
      attach_file(I18n.t('label.pick_confirmation_name.pick_confirmation_name_picture'), 'spec/fixtures/actions.png')
    end
  end

  def get_img_src_selector
    "img[src=\"/#{@dev}event_with_picture_image/#{@candidate.id}/confirmation_name\"]"
  end

  def update_pick_confirmation_name(with_values)
    if with_values
      @candidate.pick_confirmation_name.saint_name=SAINT_NAME
      @candidate.save
    end
  end
end