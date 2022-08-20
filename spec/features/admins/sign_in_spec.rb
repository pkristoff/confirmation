# frozen_string_literal: true

# Feature: Sign in
#   As a admin
#   I want to sign in
#   So I can visit protected areas of the site
describe 'Sign in', :devise do
  before do
    FactoryBot.create(:visitor)
  end

  context 'without Admin' do
    # it: Admin cannot sign in if not registered
    #   Given I do not exist as a admin
    #   When I sign in with valid credentials
    #   Then I see an invalid credentials message
    it 'admin cannot sign in if not registered' do
      signin_admin('Admin', 'please123')
      expect_message(:flash_alert, I18n.t('devise.failure.not_found_in_database', authentication_keys: 'Account name'))
    end
  end

  context 'with Admin' do
    # it: Admin cannot sign in with wrong email
    #   Given I exist as a admin
    #   And I am not signed in
    #   When I sign in with a wrong email
    #   Then I see an invalid email message
    it 'admin cannot sign in with wrong email' do
      admin = FactoryBot.create(:admin)
      signin_admin('invalid', admin.password)
      expect_message(:flash_alert, I18n.t('devise.failure.not_found_in_database', authentication_keys: 'Account name'))
    end

    # it: Admin cannot sign in with wrong password
    #   Given I exist as a admin
    #   And I am not signed in
    #   When I sign in with a wrong password
    #   Then I see an invalid password message
    it 'admin cannot sign in with wrong password' do
      admin = FactoryBot.create(:admin)
      signin_admin(admin.email, 'invalidpass')
      expect_message(:flash_alert, I18n.t('devise.failure.not_found_in_database', authentication_keys: 'Account name'))
    end

    # it: Admin can sign in with valid credentials
    #   Given I exist as a admin
    #   And I am not signed in
    #   When I sign in with valid credentials
    #   Then I see a success message
    it 'admin can sign in with valid credentials' do
      FactoryBot.create(:admin) do |admin|
        signin_admin(admin.account_name, admin.password)
        expect_message(:flash_notice, I18n.t('devise.sessions.signed_in'))
      end
    end
  end
end
