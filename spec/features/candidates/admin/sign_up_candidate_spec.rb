# Feature: Sign up
#   As a visitor
#   I want to sign up
#   So I can visit protected areas of the site
feature 'Sign Up', :devise do

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
      admin = FactoryGirl.create(:admin)
      signin_admin(admin.email, admin.password)
    end

    # Scenario: Visitor can sign up with valid email address and password
    #   Given I am not signed in
    #   When I sign up with a valid email address and password
    #   Then I see a successful sign up message
    scenario 'visitor can sign up with valid candidate id, email address and password' do
      visit new_candidate_path
      expect(page).to have_selector('p', text: 'This has been turned off')
    end

  end

end
