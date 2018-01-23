shared_context 'candidate_sheet_html_erb' do

  before(:each) do

    AppFactory.add_confirmation_events
    @candidate = Candidate.find_by_account_name(@candidate.account_name)

  end

  scenario 'candidate logs in, selects candidate sheet, attempts to save an invalid sheet' do
    cand = Candidate.find(@candidate.id)
    cand.candidate_sheet.candidate_email = 'm'
    cand.save(validate: false)

    visit @path
    expect_candidate_sheet_form(@candidate.id, @path_str, @dev, @update_id)

    click_button(@update_id)

    expect_candidate_sheet_form(@candidate.id, @path_str, @dev, @update_id,
                                expect_messages: [
                                    [:flash_notice, @updated_failed_verification],
                                    [:error_explanation, 'Your changes were saved!! 1 empty field needs to be filled in on the form to be verfied: Candidate email is an invalid email: m']
                                ]
    )
  end

  scenario 'candidate logs in, selects candidate sheet, has filled out candidate sheet previsouly puts in invalid email, attempts to save an invalid sheet' do
    visit @path
    fill_in(I18n.t('label.candidate_sheet.candidate_email'), with: 'mm')

    click_button(@update_id)

    expect_candidate_sheet_form(@candidate.id, @path_str, @dev, @update_id,
                                expect_messages: [
                                    [:flash_notice, @updated_failed_verification],
                                    [:error_explanation, 'Your changes were saved!! 1 empty field needs to be filled in on the form to be verfied: Candidate email is an invalid email: mm']
                                ]
    )
  end

  scenario 'candidate fills out candidate sheet' do

    expect_db(1, 9, 0)

    visit @path

    candidate_event = @candidate.get_candidate_event(I18n.t('events.candidate_information_sheet'))
    candidate_sheet = @candidate.candidate_sheet
    candidate_sheet.candidate_email = 'can.didate@email.com'

    fill_in_form(candidate_sheet)

    click_button(@update_id)

    if @admin_verified

      candidate = Candidate.find(@candidate.id)
      expect_mass_edit_candidates_event(ConfirmationEvent.find_by_name(I18n.t('events.candidate_information_sheet')), candidate, @updated_message)

    else

      expect_candidate_sheet_form(@candidate.id, @path_str, @dev, @update_id,
                                  expect_messages: [[:flash_notice, @updated_message]]
      )

    end

    expect_db(1, 9, 0) #make sure DB does not increase in size.
  end

  def expect_candidate_sheet_form(cand_id, path_str, dev_path, update_id, values = {})

    expect_messages(values[:expect_messages]) unless values[:expect_messages].nil?

    expect(page).to have_selector('h2', text: I18n.t('events.candidate_information_sheet'))

    expect(page).to have_selector("form[id=edit_candidate][action=\"/#{dev_path}#{path_str}.#{cand_id}\"]")

    cand = Candidate.find(cand_id)
    candidate_sheet = cand.candidate_sheet
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

    expect(page).to have_button(update_id)
  end

  def fill_in_form(candidate_sheet)
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
  end

end
