# Feature: Sign in
#   As a admin
#   I want to sign in
#   So I can visit protected areas of the site
feature 'Sign in', :devise do

  context "I do not exist as an Admin" do

    # Scenario: Admin cannot sign in if not registered
    #   Given I do not exist as a admin
    #   When I sign in with valid credentials
    #   Then I see an invalid credentials message
    scenario 'admin cannot sign in if not registered' do
      signin_admin('test@example.com', 'please123')
      expect(page).to have_selector('div[id=flash_alert]', text: I18n.t('devise.failure.not_found_in_database', authentication_keys: 'email'))
    end

  end

  context "I exist as an Admin" do

    # Scenario: Admin cannot sign in with wrong email
    #   Given I exist as a admin
    #   And I am not signed in
    #   When I sign in with a wrong email
    #   Then I see an invalid email message
    scenario 'admin cannot sign in with wrong email' do
      admin = FactoryGirl.create(:admin)
      signin_admin('invalid@email.com', admin.password)
      expect(page).to have_selector('div[id=flash_alert]', text: I18n.t('devise.failure.not_found_in_database', authentication_keys: 'email'))
    end

    # Scenario: Admin cannot sign in with wrong password
    #   Given I exist as a admin
    #   And I am not signed in
    #   When I sign in with a wrong password
    #   Then I see an invalid password message
    scenario 'admin cannot sign in with wrong password' do
      admin = FactoryGirl.create(:admin)
      signin_admin(admin.email, 'invalidpass')
      expect(page).to have_selector('div[id=flash_alert]', text: I18n.t('devise.failure.not_found_in_database', authentication_keys: 'email'))
    end
    # Scenario: Admin can sign in with valid credentials
    #   Given I exist as a admin
    #   And I am not signed in
    #   When I sign in with valid credentials
    #   Then I see a success message
    scenario 'admin can sign in with valid credentials' do
      # skip 'works when debugging but not in straight mode - sign in'
      FactoryGirl.create(:admin) do |admin|
        signin_admin(admin.email, admin.password)
        expect(page).to have_selector('div[id=flash_notice]', text: I18n.t('devise.sessions.signed_in'))
      end
    end
  end

end
