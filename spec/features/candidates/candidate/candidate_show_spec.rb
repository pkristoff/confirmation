include Warden::Test::Helpers
Warden.test_mode!

# Feature: Candidate profile page
#   As a candidate
#   I want to visit my candidate profile page
#   So I can see my personal account data
feature 'Candidate profile page', :devise do

  after(:each) do
    Warden.test_reset!
  end

  # Scenario: Candidate sees own profile
  #   Given I am signed in
  #   When I visit the candidate profile page
  #   Then I see my own email address
  scenario 'candidate sees own profile' do
    candidate = FactoryGirl.create(:candidate)
    login_as(candidate, :scope => :candidate)
    visit dev_candidate_path(candidate)
    expect(page).to have_content 'Candidate'
    expect(page).to have_content candidate.parent_email_1
  end

  # Scenario: Candidate cannot see another candidate's profile
  #   Given I am signed in
  #   When I visit another candidate's profile
  #   Then I see an 'access denied' message
  scenario "candidate cannot see another candidate's profile" do
    me = FactoryGirl.create(:candidate)
    other = FactoryGirl.create(:candidate, parent_email_1: 'other@example.com', candidate_id: 'other')
    login_as(me, :scope => :candidate)
    Capybara.current_session.driver.header 'Referer', dev_candidate_path(me)
    visit dev_candidate_path(other)
    expect(page).to have_selector('div[id=flash_alert]', text: 'Access denied.')
  end

end
