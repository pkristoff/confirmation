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
    # skip 'works when debugging but not in straight mode - sign in'
    admin = FactoryGirl.create(:admin)
    signin_admin(admin.email, admin.password)
    expect(page).to have_selector('div[id=flash_notice]', text: I18n.t('devise.sessions.signed_in'))
    click_link 'Sign out'
    expect(page).to have_selector('div[id=flash_notice]', text: I18n.t('devise.sessions.signed_out'))
  end

end


