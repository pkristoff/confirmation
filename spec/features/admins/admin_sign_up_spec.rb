# frozen_string_literal: true

Warden.test_mode!

# Feature: Admin edit
#   As a admin
#   I want to edit my admin profile
#   So I can change my email address
feature 'Admin sign up', :devise do
  include Warden::Test::Helpers

  after(:each) do
    Warden.test_reset!
  end

  # Scenario: only an admin can sign up another admin
  #   Given no one is signed in
  #   When i click sign up
  #   Then I am blocked from creating an admin
  scenario 'attempt to sign up a new admin with no one signed in' do
    referer = new_admin_session_path
    Capybara.current_session.driver.header 'Referer', referer
    visit new_admin_registration_path # click Sign up admin
    expect(page.current_path).to eq(referer)
    expect_message(:flash_alert, I18n.t('messages.admin_login_needed', message: I18n.t('messages.another_admin')))
  end

  # Scenario: only an admin can sign up another admin 2
  #   Given candidate is signed in (not admin)
  #   When i click sign up
  #   Then I am blocked from creating an admin
  scenario 'only an admin can sign up another admin' do
    candidate = FactoryBot.create(:candidate)
    login_as(candidate, scope: :candidate)
    referer = new_admin_session_path
    Capybara.current_session.driver.header 'Referer', referer
    visit new_admin_registration_path # click Sign up admin
    expect(page.current_path).to eq(referer)
    expect_message(:flash_alert, I18n.t('messages.admin_login_needed', message: I18n.t('messages.another_admin')))
  end

  describe 'Sign in admin' do
    before(:each) do
      admin = FactoryBot.create(:admin)
      signin_admin(admin.account_name, admin.password)
    end

    # Scenario: Admin  can sign up another admin
    #   Given I am signed in as admin
    #   When i click admin sign up
    #   Then I am not blocked because i am logged in
    scenario 'admin can sign up another admin' do
      visit new_admin_registration_path # click Sign up admin
      expect(page).to have_selector('p', text: 'This is turned off')
    end

    # Scenario: Visitor cannot sign up - ony admin can create a new candidate
    #   Given I am not signed in
    #   When I sign up with a valid email address and password
    #   Then I see a successful sign up message
    # scenario 'visitor can sign up with valid email address and password' do
    #   visit new_admin_registration_path
    #   expect(page).to have_selector('p', count: 3)
    #   expect(page).to have_selector('h3', text: 'Admin')
    #   expect(page).to have_selector('p', text: 'Name: Admin Candidate')
    #   expect(page).to have_selector('p', text: 'Email: test@example.com')
    # sign_up_admin_with('test1@example.com', 'please123', 'please123')
    # txts = [I18n.t('devise.registrations.signed_up'), I18n.t('devise.registrations.signed_up_but_unconfirmed')]
    # expect_message :flash_notice, /.*#{txts[0]}.*|.*#{txts[1]}.*/
    # end

    # Scenario: Visitor cannot sign up with invalid email address
    #   Given I am not signed in
    #   When I sign up with an invalid email address
    #   Then I see an invalid email message
    # scenario 'visitor cannot sign up with invalid email address' do
    #   sign_up_admin_with('bogus', 'please123', 'please123')
    #   expect_message :error_explanation, 'Email is invalid'
    # end

    # Scenario: Visitor cannot sign up without password
    #   Given I am not signed in
    #   When I sign up without a password
    #   Then I see a missing password message
    # scenario 'visitor cannot sign up without password' do
    #   sign_up_admin_with('test1@example.com', '', '')
    #   expect_message :error_explanation, 'Password can\'t be blank'
    # end

    # Scenario: Visitor cannot sign up with a short password
    #   Given I am not signed in
    #   When I sign up with a short password
    #   Then I see a 'too short password' message
    # scenario 'visitor cannot sign up with a short password' do
    #   sign_up_admin_with('test1@example.com', 'please', 'please')
    #   expect_message :error_explanation, 'Password is too short'
    # end

    # Scenario: Visitor cannot sign up without password confirmation
    #   Given I am not signed in
    #   When I sign up without a password confirmation
    #   Then I see a missing password confirmation message
    # scenario 'visitor cannot sign up without password confirmation' do
    #   sign_up_admin_with('test1@example.com', 'please123', '')
    #   expect_message :error_explanation, 'Password confirmation doesn\'t match'
    # end

    # Scenario: Visitor cannot sign up with mismatched password and confirmation
    #   Given I am not signed in
    #   When I sign up with a mismatched password confirmation
    #   Then I should see a mismatched password message
    # scenario 'visitor cannot sign up with mismatched password and confirmation' do
    #   sign_up_admin_with('test1@example.com', 'please123', 'mismatch')
    #   expect_message :error_explanation, 'Password confirmation doesn\'t match'
    # end

    # Scenario: admin can create another admin
    #   Given I am signed in (me)
    #   admin clicks admin sign up
    #   admin fills in fields
    #   Then I see list of admins including me & new admin
    scenario 'admin can NOT create another admin', :me do
      visit new_admin_registration_path # click Sign up admin
      expect(page).to have_selector('p', text: 'This is turned off')
    end
  end
end
