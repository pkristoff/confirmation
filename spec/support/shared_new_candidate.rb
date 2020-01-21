# frozen_string_literal: true

# Feature: Sign up
#   As a visitor
#   I want to sign up
#   So I can visit protected areas of the site
shared_context 'new_candidate_spec' do
  include ViewsHelpers
  before(:each) do
    page.driver.header 'Accept-Language', locale
    I18n.locale = locale
  end

  # Scenario: Visitor cannot sign up without logging in
  #   Given I am not signed in
  #   When I sign up with a valid email address and password
  #   Then I see a successful sign up message
  scenario 'Visitor cannot sign up without logging in' do
    visit new_candidate_path
    expect_message(:flash_alert, I18n.t('devise.failure.unauthenticated'))
  end

  describe 'Sign in admin' do
    before(:each) do
      admin = FactoryBot.create(:admin)
      signin_admin(admin.account_name, admin.password)
      AppFactory.add_confirmation_events
    end

    # Scenario: Admin can create a new candidate
    #   Given Admin si signed in
    scenario 'visitor can sign up with valid candidate id, email address and password' do
      visit new_candidate_path

      expect_create_candidate(page)
    end

    scenario 'admin cannot create candidate with no emails' do
      visit new_candidate_path

      fill_in_form_values

      fill_in(I18n.t('label.candidate_sheet.candidate_email'), with: '')

      click_button I18n.t('views.common.update')

      expect_messages([[:error_explanation, [I18n.t('errors.messages.not_saved.one', resource: :candidate),
                                             I18n.t('messages.error.one_email')]],
                       [:flash_alert, I18n.t('views.common.save_failed', failee: 'George Smith')]])

      expect(Candidate.all.size).to eq(0)
    end

    scenario 'admin can create candidate with missing middle name' do
      visit new_candidate_path

      fill_in_form_values
      fill_in(I18n.t('label.candidate_sheet.middle_name'), with: '')

      click_button I18n.t('views.common.update')

      expect_messages([[:flash_notice, I18n.t('views.candidates.created', account: 'smithgeorge', name: 'George Smith')]])

      expect(Candidate.all.size).to eq(1)
    end

    scenario 'admin cannot create candidate with missing first name' do
      visit new_candidate_path

      fill_in_form_values
      fill_in(I18n.t('label.candidate_sheet.first_name'), with: '')

      click_button I18n.t('views.common.update')

      expect_messages([[:error_explanation, [I18n.t('errors.messages.not_saved.one', resource: :candidate),
                                             "Candidate sheet first name #{I18n.t('errors.messages.blank')}"]],
                       [:flash_alert, I18n.t('views.common.save_failed', failee: 'Smith')]])

      expect(Candidate.all.size).to eq(0)
    end

    scenario 'admin cannot create candidate with missing last name but can after correcting it' do
      visit new_candidate_path

      fill_in_form_values

      fill_in(I18n.t('label.candidate_sheet.last_name'), with: '')

      click_button I18n.t('views.common.update')

      expect_messages([[:error_explanation, [I18n.t('errors.messages.not_saved.one', resource: :candidate),
                                             "Candidate sheet last name #{I18n.t('errors.messages.blank')}"]],
                       [:flash_alert, I18n.t('views.common.save_failed', failee: 'George')]])

      expect(Candidate.all.size).to eq(0)

      fill_in(I18n.t('label.candidate_sheet.last_name'), with: 'Smith')

      click_button I18n.t('views.common.update')

      expect_messages([[:flash_notice, I18n.t('views.candidates.created', account: 'smithgeorge', name: 'George Smith')]])

      expect(Candidate.all.size).to eq(1)
    end

    scenario 'admin cannot create candidate with an invalid email' do
      visit new_candidate_path

      fill_in_form_values

      fill_in(I18n.t('label.candidate_sheet.candidate_email'), with: 'Smithgr@.com')

      click_button I18n.t('views.common.update')

      expect_messages([[:error_explanation, [I18n.t('errors.messages.not_saved.one', resource: :candidate),
                                             "Candidate email #{I18n.t('messages.error.invalid_email', email: 'smithgr@.com')}"]],
                       [:flash_alert, I18n.t('views.common.save_failed', failee: 'George')]])

      expect(Candidate.all.size).to eq(0)
    end

    scenario 'admin can create 2 candidates in a row' do
      visit new_candidate_path

      fill_in_form_values

      click_button I18n.t('views.common.update')

      expect_messages([[:flash_notice, I18n.t('views.candidates.created', account: 'smithgeorge', name: 'George Smith')]])

      expect(page).to have_field(I18n.t('views.candidates.first_name'), text: '')

      expect(Candidate.all.size).to eq(1)

      expect(Candidate.first.account_name).to eq('smithgeorge')

      fill_in_form_values('Paul', 'eee', 'Yyy')

      click_button I18n.t('views.common.update')

      expect(Candidate.all.size).to eq(2)
    end
  end

  def fill_in_form_values(first = 'George', middle = 'Ralph', last = 'Smith', email = 'Smithgr@gmail.com')
    fill_in(I18n.t('views.candidates.first_name'), with: first)
    fill_in(I18n.t('views.candidates.middle_name'), with: middle)
    fill_in(I18n.t('views.candidates.last_name'), with: last)

    fill_in(I18n.t('label.candidate_sheet.candidate_email'), with: email)
    fill_in(I18n.t('label.candidate_sheet.parent_email_1'), with: '')
    fill_in(I18n.t('label.candidate_sheet.parent_email_2'), with: '')

    fill_in(I18n.t('label.candidate_sheet.grade'), with: 10)
  end
end
