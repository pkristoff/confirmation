include Warden::Test::Helpers
Warden.test_mode!

# Feature: User delete
#   As a admin
#   I want to delete my admin profile
#   So I can close my account
feature 'User delete', :devise, :js do

  after(:each) do
    Warden.test_reset!
  end

  # Scenario: User can delete own account
  #   Given I am signed in
  #   When I delete my account
  #   Then I should see an account deleted message
  scenario 'admin can delete own account' do
    skip 'skip a slow test'
    admin = FactoryGirl.create(:admin)
    login_as(admin, :scope => :admin)
    visit edit_admin_registration_path(admin)
    click_button 'Cancel my account'
    page.driver.browser.switch_to.alert.accept
    expect(page).to have_content I18n.t 'devise.registrations.destroyed'
  end

end




