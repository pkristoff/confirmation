# frozen_string_literal: true

# Feature: Sign up
#   only Admin can signup a candidate
feature 'Sign Up', :devise do
  # Scenario: Candidate cannot sign up another candidate
  #   Given I am not signed in
  #   When I sign up with a valid account_name and password
  #   Then I see a Please login as admin to create another candidate.
  scenario 'Candidate cannot sign up another candidate' do
    FactoryBot.create(:candidate)
    referer = new_candidate_session_path
    Capybara.current_session.driver.header 'Referer', referer
    visit new_candidate_registration_path
    expect(page.current_path).to eq(referer)
    expect_message(:flash_alert, I18n.t('messages.admin_login_needed', message: I18n.t('messages.another_candidate')))
  end
end
