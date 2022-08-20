# frozen_string_literal: true

# Feature: Sign out
#   As a candidate
#   I want to sign out
#   So I can protect my account from unauthorized access
describe 'Sign out', :devise do
  before do
    FactoryBot.create(:visitor)
  end

  # it: Candidate signs out successfully
  #   Given I am signed in
  #   When I sign out
  #   Then I see a signed out message
  it 'candidate signs out successfully' do
    admin = FactoryBot.create(:admin)
    signin_admin(admin.account_name, admin.password)
    expect_message(:flash_notice, I18n.t('devise.sessions.signed_in'))
    click_link I18n.t('views.top_bar.sign_out')
    expect_message(:flash_notice, I18n.t('devise.sessions.signed_out'))
  end
end
