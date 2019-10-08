# frozen_string_literal: true

Warden.test_mode!

# Feature: Candidate delete
#   As a admin
#   I want to delete my admin profile
#   So I can close my account
feature 'Admin delete', :devise do
  include Warden::Test::Helpers

  after(:each) do
    Warden.test_reset!
  end

  # Scenario: Candidate can delete own account
  #   Given I am signed in
  #   When I delete my account
  #   Then I should see an account deleted message
  # scenario 'admin cannot delete own account' do
  #   admin = FactoryBot.create(:admin)
  #   # other = FactoryBot.create(:admin, email: 'other@test.com', name: 'other')
  #   expect(Admin.all.size).to eq(1)
  #   login_as(admin, scope: :admin)
  #   visit admins_path
  #   click_link "delete_#{admin.id}"
  #   expect_message(:flash_notice, I18n.t('devise.registrations.destroyed'))
  #
  #   expect(Admin.all.size).to eq(1)
  # end
end
