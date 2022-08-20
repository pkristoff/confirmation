# frozen_string_literal: true

Warden.test_mode!

# Feature: Candidate profile page
#   As a candidate
#   I want to visit my candidate profile page
#   So I can see my personal account data
describe 'Candidate profile page', :devise do
  include Warden::Test::Helpers

  after do
    Warden.test_reset!
  end

  # it: Candidate sees own profile
  #   Given I am signed in
  #   When I visit the candidate profile page
  #   Then I see my own email address
  it 'candidate sees own profile' do
    candidate = FactoryBot.create(:candidate)
    login_as(candidate, scope: :candidate)
    visit dev_candidate_path(candidate)
    expect(page).to have_content 'Candidate'
    expect(page).to have_content candidate.candidate_sheet.parent_email_1
  end

  # it: Candidate cannot see another candidate's profile
  #   Given I am signed in
  #   When I visit another candidate's profile
  #   Then I see an 'access denied' message
  it "candidate cannot see another candidate's profile" do
    me = FactoryBot.create(:candidate)
    other = FactoryBot.create(:candidate, account_name: 'other')
    other.candidate_sheet.parent_email_1 = 'other@example.com'
    login_as(me, scope: :candidate)
    Capybara.current_session.driver.header 'Referer', dev_candidate_path(me)
    visit dev_candidate_path(other)
    expect_message(:flash_alert, I18n.t('messages.accessed_denied'))
  end
end
