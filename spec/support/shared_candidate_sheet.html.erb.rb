shared_context 'candidate_sheet_html_erb' do

  scenario 'candidate logs in, selects candidate sheet, has not filled out candidate sheet previsouly' do
    visit @path
    expect_form_layout
  end

  scenario 'candidate logs in, selects candidate sheet, has filled out candidate sheet previsouly' do
    visit @path
    expect_form_layout
  end

  scenario 'candidate fills out candidate sheet' do

    AppFactory.add_confirmation_event(I18n.t('events.fill_out_candidate_sheet'))

    visit @path

    click_button('Update')

    expect_message(:flash_notice, 'Updated')
    expect(page).to have_selector('div[id=candidate_event_2_verified]', text: false)
    if @dev.empty?
      expect(page).to have_field('candidate_candidate_events_attributes_2_completed_date', with: Date.today)
    else
      expect(page).to have_selector('div[id=candidate_event_2_completed_date]', text: Date.today)
    end
  end

  def expect_form_layout

    expect(page).to have_selector("form[id=edit_candidate][action=\"/#{@dev}candidate_sheet.#{@candidate.id}\"]")


    expect(page).to have_field('First name', with: @candidate.first_name, type: 'text')
    expect(page).to have_field('Last name', with: @candidate.last_name, type: 'text')

    expect(page).to have_field('candidate_address_attributes_street_1', with: @candidate.address.street_1, type: 'text')
    expect(page).to have_field('candidate_address_attributes_street_2', with: @candidate.address.street_2, type: 'text')
    expect(page).to have_field('candidate_address_attributes_city', with: @candidate.address.city, type: 'text')
    expect(page).to have_field('candidate_address_attributes_state', with: @candidate.address.state, type: 'text')
    expect(page).to have_field('candidate_address_attributes_zip_code', with: @candidate.address.zip_code, type: 'text')

    expect(page).to have_field('Grade', with: @candidate.grade, type: 'number')

    expect(page).to have_field('Candidate email', with: @candidate.candidate_email, type: 'email')
    expect(page).to have_field('Parent email 1', with: @candidate.parent_email_1, type: 'email')
    expect(page).to have_field('Parent email 2', with: @candidate.parent_email_2, type: 'email')

    expect(page).to have_button(I18n.t('views.common.update'))
  end

end
