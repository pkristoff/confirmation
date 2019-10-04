# frozen_string_literal: true

# Feature: Sign up
#   As a visitor
#   I want to sign up
#   So I can visit protected areas of the site
feature 'Sign Up', :devise do
  include ViewsHelpers
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
      signin_admin(admin.email, admin.password)
    end

    # Scenario: Visitor can sign up with valid email address and password
    #   Given I am not signed in
    #   When I sign up with a valid email address and password
    #   Then I see a successful sign up message
    scenario 'visitor can sign up with valid candidate id, email address and password' do
      visit new_candidate_path
      expect_create_candidate(page)
    end
    scenario 'admin cannot create candidate with missing first name' do
      visit new_candidate_path

      fill_in('Middle name', with: 'Ralph')
      fill_in('Last name', with: 'Smith')

      fill_in('Candidate email', with: 'Smithgr@gmaail.com')
      fill_in('Parent email 1', with: 'Smithav@gmail.com')
      fill_in('Parent email 2', with: 'Smithbc@gmail.com')

      fill_in('Grade', with: 11)

      click_button 'Update'

      expect_messages([[:error_explanation, ['1 error prohibited this candidate from being saved:', 'Candidate sheet first name can\'t be blank']],
                       [:flash_alert, 'Save of creation of candidate failed: Smith']])

      expect(Candidate.all.size).to eq(0)
    end
    scenario 'admin cannot create candidate with missing last name' do
      visit new_candidate_path

      fill_in('First name', with: 'George')
      fill_in('Middle name', with: 'Ralph')

      fill_in('Candidate email', with: 'Smithgr@gmaail.com')
      fill_in('Parent email 1', with: 'Smithav@gmail.com')
      fill_in('Parent email 2', with: 'Smithbc@gmail.com')

      fill_in('Grade', with: 11)

      click_button 'Update'

      expect_messages([[:error_explanation, ['1 error prohibited this candidate from being saved:', 'Candidate sheet last name can\'t be blank']],
                       [:flash_alert, 'Save of creation of candidate failed: George']])

      expect(Candidate.all.size).to eq(0)
    end

    scenario 'admin cannot create candidate with an invalid email' do
      AppFactory.add_confirmation_events
      visit new_candidate_path

      fill_in('First name', with: 'George')
      fill_in('Middle name', with: 'Ralph')
      fill_in('Last name', with: 'Smith')

      fill_in('Candidate email', with: 'Smithgr@.com')
      fill_in('Parent email 1', with: 'Smithav@gmail.com')
      fill_in('Parent email 2', with: 'Smithbc@gmail.com')

      click_button 'Update'

      expect(Candidate.all.size).to eq(1)
    end
  end
end
