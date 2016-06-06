include Warden::Test::Helpers
Warden.test_mode!

# Feature: Candidate delete
#   As a admin
#   I want to delete my admin profile
#   So I can close my account
feature 'Admin delete', :devise do

  after(:each) do
    Warden.test_reset!
  end

  # Scenario: Candidate can delete own account
  #   Given I am signed in
  #   When I delete my account
  #   Then I should see an account deleted message
  scenario 'admin can delete own account' do
    admin = FactoryGirl.create(:admin)
    login_as(admin, :scope => :admin)
    visit edit_admin_registration_path(admin)
    click_button I18n.t('views.admins.cancel_my_account')
    expect(page).to have_selector('div[id=flash_notice]', text: I18n.t('devise.registrations.destroyed'))
  end

end




