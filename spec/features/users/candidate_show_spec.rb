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
    visit candidate_path(candidate)
    expect(page).to have_content 'Candidate'
    expect(page).to have_content candidate.email
  end

  # Scenario: Candidate cannot see another candidate's profile
  #   Given I am signed in
  #   When I visit another candidate's profile
  #   Then I see an 'access denied' message
  scenario "candidate cannot see another candidate's profile" do
    me = FactoryGirl.create(:candidate)
    other = FactoryGirl.create(:candidate, email: 'other@example.com', name: 'other')
    login_as(me, :scope => :candidate)
    Capybara.current_session.driver.header 'Referer', root_path
    visit candidate_path(other)
    expect(page).to have_content 'Access denied.'
  end

end
