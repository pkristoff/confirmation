# frozen_string_literal: true

Warden.test_mode!

# Feature: Candidate delete
#   As a candidate
#   I want to delete my candidate profile
#   So I can close my account
describe 'Candidate delete', :devise do
  include Warden::Test::Helpers

  after do
    Warden.test_reset!
  end

  # it: Candidate can delete own account
  #   Given I am signed in
  #   When I delete my account
  #   Then I should see an account deleted message
  it 'candidate can delete own account' do
    candidate = FactoryBot.create(:candidate)
    login_as(candidate, scope: :candidate)
    visit edit_candidate_registration_path(candidate)
  end
end
