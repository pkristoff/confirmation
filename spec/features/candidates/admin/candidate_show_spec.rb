# frozen_string_literal: true

Warden.test_mode!

# Feature: Candidate profile page
#   As a candidate
#   I want to visit my candidate profile page
#   So I can see my personal account data
feature 'Candidate profile page', :devise do
  include Warden::Test::Helpers

  after(:each) do
    Warden.test_reset!
  end

  # Scenario: Admin sees candidate profile
  #   Given Admin is signed in
  #   When I visit the candidate profile page
  #   Then I see account_name
  scenario 'candidate sees own profile' do
    admin = FactoryBot.create(:admin)
    candidate = FactoryBot.create(:candidate)
    candidate2 = FactoryBot.create(:candidate, account_name: 'other')
    login_as(admin, scope: :admin)
    visit candidate_path(candidate)
    expect(page).to have_content 'Candidate'
    expect(page).to have_content candidate.account_name
    visit candidate_path(candidate2)
    expect(page).to have_content 'Candidate'
    expect(page).to have_content candidate2.account_name
  end
end
