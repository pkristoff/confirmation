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
    expect(page).to have_selector('div[id=flash_alert]', text: 'You need to sign in or sign up before continuing.')
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
      sign_up_candidate_with('candidateId', 'test@example.com', 'please123', 'please123')
      expect(page).to have_selector('div[id=flash_notice]', text: I18n.t('devise.registrations.signed_up'))
    end

    # Scenario: Visitor cannot sign up with invalid email address
    #   Given I am not signed in
    #   When I sign up with an invalid email address
    #   Then I see an invalid email message
    scenario 'visitor cannot sign up with invalid candidate id' do
      sign_up_candidate_with('', 'test@example.com', 'please123', 'please123')
      expect(page).to have_content 'Candidate can\'t be blank'
    end

    # Scenario: Visitor cannot sign up without password
    #   Given I am not signed in
    #   When I sign up without a password
    #   Then I see a missing password message
    scenario 'visitor cannot sign up without password' do
      sign_up_candidate_with('candidateId', 'test@example.com', '', '')
      expect(page).to have_content 'Password can\'t be blank'
    end

    # Scenario: Visitor cannot sign up with a short password
    #   Given I am not signed in
    #   When I sign up with a short password
    #   Then I see a 'too short password' message
    scenario 'visitor cannot sign up with a short password' do
      sign_up_candidate_with('candidateId', 'test@example.com', 'please', 'please')
      expect(page).to have_content 'Password is too short'
    end

    # Scenario: Visitor cannot sign up without password confirmation
    #   Given I am not signed in
    #   When I sign up without a password confirmation
    #   Then I see a missing password confirmation message
    scenario 'visitor cannot sign up without password confirmation' do
      sign_up_candidate_with('candidateId', 'test@example.com', 'please123', '')
      expect(page).to have_content 'Password confirmation doesn\'t match'
    end

    # Scenario: Visitor cannot sign up with mismatched password and confirmation
    #   Given I am not signed in
    #   When I sign up with a mismatched password confirmation
    #   Then I should see a mismatched password message
    scenario 'visitor cannot sign up with mismatched password and confirmation' do
      sign_up_candidate_with('candidateId', 'test@example.com', 'please123', 'mismatch')
      expect(page).to have_content 'Password confirmation doesn\'t match'
    end

  end

end
