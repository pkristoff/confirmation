SAINT_NAME = 'George Sponsor'


shared_context 'pick_confirmation_name_html_erb' do

  before(:each) do
    AppFactory.add_confirmation_events
    @candidate = Candidate.find_by_account_name(@candidate.account_name)
  end

  scenario 'admin logs in and selects a candidate, nothing else showing' do
    update_pick_confirmation_name(false)
    visit @path
    expect_form_layout(@candidate, false)
  end

  scenario 'admin logs in and selects a candidate, fills in template' do
    update_pick_confirmation_name(false)
    visit @path
    fill_in_form
    click_button 'top-update'

    expect_message(:flash_notice, I18n.t('messages.updated'))
    candidate = Candidate.find(@candidate.id)
    expect(candidate.pick_confirmation_name.saint_name).to eq(SAINT_NAME)

    expect(candidate.get_candidate_event(I18n.t('events.confirmation_name')).completed_date).to eq(Date.today)
    expect(candidate.get_candidate_event(I18n.t('events.confirmation_name')).verified).to eq(false)
  end

  scenario 'admin logs in and selects a candidate, adds picture, updates, adds rest of valid data, updates - everything is saved' do
    AppFactory.add_candidate_events(@candidate)
    update_pick_confirmation_name(false)
    visit @path

    click_button 'top-update'

    candidate = Candidate.find(@candidate.id)
    expect_message(:error_explanation, ['1 empty field need to be filled in', 'Saint name can\'t be blank'])

    expect(candidate.pick_confirmation_name.saint_name).to eq('')

    fill_in_form # no picture
    click_button 'top-update'

    expect_message(:flash_notice, I18n.t('messages.updated'))
    candidate = Candidate.find(@candidate.id)
    expect(candidate.pick_confirmation_name.saint_name).to eq(SAINT_NAME)

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

    expect(page).to have_selector("form[id=edit_candidate][action=\"/#{@dev}pick_confirmation_name.#{@candidate.id}\"]")

    expect_field(I18n.t('label.confirmation_name.saint_name'), with_values ? saint_name : '')

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

  def fill_in_form
    fill_in(I18n.t('label.confirmation_name.saint_name'), with: SAINT_NAME)
  end

  def update_pick_confirmation_name(with_values)
    if with_values
      @candidate.pick_confirmation_name.saint_name=SAINT_NAME
      @candidate.save
    end
  end
end