# Feature: Sign out
#   As a candidate
#   I want to sign out
#   So I can protect my account from unauthorized access
feature 'Sign out', :devise do

  # Scenario: Candidate signs out successfully
  #   Given I am signed in
  #   When I sign out
  #   Then I see a signed out message
  scenario 'candidate signs out successfully' do
    admin = FactoryGirl.create(:admin)
    signin_admin(admin.email, admin.password)
    expect_message(:flash_notice, I18n.t('devise.sessions.signed_in'))
    click_link I18n.t('views.common.sign_out')
    expect_message(:flash_notice, I18n.t('devise.sessions.signed_out'))
  end

end


