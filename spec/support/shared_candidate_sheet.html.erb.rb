shared_context 'candidate_sheet_html_erb' do

  before(:each) do

    AppFactory.add_confirmation_events
    @candidate = Candidate.find_by_account_name(@candidate.account_name)

  end

  scenario 'candidate logs in, selects candidate sheet, has not filled out candidate sheet previsouly' do
    visit @path
    expect_form_layout
  end

  scenario 'candidate logs in, selects candidate sheet, has filled out candidate sheet previsouly' do
    visit @path
    expect_form_layout
  end

  scenario 'candidate fills out candidate sheet' do

    visit @path

    candidate_event = @candidate.get_candidate_event(I18n.t('events.candidate_information_sheet'))
    candidate_sheet = @candidate.candidate_sheet
    candidate_sheet.candidate_email = 'can.didate@email.com'

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

    click_button('top-update')

    expect_message(:flash_notice, 'Updated')
    expect(page).to have_selector('h2', text: I18n.t('events.candidate_information_sheet'))
  end

  def expect_form_layout

    expect(page).to have_selector("form[id=edit_candidate][action=\"/#{@dev}candidate_sheet.#{@candidate.id}\"]")

    candidate_sheet = @candidate.candidate_sheet
    expect(page).to have_field(I18n.t('label.candidate_sheet.first_name'), with: candidate_sheet.first_name, type: 'text')
    expect(page).to have_field(I18n.t('label.candidate_sheet.middle_name'), with: candidate_sheet.middle_name, type: 'text')
    expect(page).to have_field(I18n.t('label.candidate_sheet.last_name'), with: candidate_sheet.last_name, type: 'text')

    expect(page).to have_field(I18n.t('label.candidate_sheet.address.street_1'), with: candidate_sheet.address.street_1, type: 'text')
    expect(page).to have_field(I18n.t('label.candidate_sheet.address.street_2'), with: candidate_sheet.address.street_2, type: 'text')
    expect(page).to have_field(I18n.t('label.candidate_sheet.address.city'), with: candidate_sheet.address.city, type: 'text')
    expect(page).to have_field(I18n.t('label.candidate_sheet.address.state'), with: candidate_sheet.address.state, type: 'text')
    expect(page).to have_field(I18n.t('label.candidate_sheet.address.zip_code'), with: candidate_sheet.address.zip_code, type: 'text')

    expect(page).to have_field(I18n.t('label.candidate_sheet.grade'), with: candidate_sheet.grade, type: 'number')

    expect(page).to have_field(I18n.t('label.candidate_sheet.candidate_email'), with: candidate_sheet.candidate_email, type: 'email')
    expect(page).to have_field(I18n.t('label.candidate_sheet.parent_email_1'), with: candidate_sheet.parent_email_1, type: 'email')
    expect(page).to have_field(I18n.t('label.candidate_sheet.parent_email_2'), with: candidate_sheet.parent_email_2, type: 'email')

    expect(page).to have_button(I18n.t('views.common.update'))
  end

end
