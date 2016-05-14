include Warden::Test::Helpers
Warden.test_mode!

# Feature: Candidate index page
#   As a candidate
#   I want to see a list of candidates
#   So I can see who has registered
feature 'Candidate index page', :devise do

  after(:each) do
    Warden.test_reset!
  end

  # Scenario: Candidate listed on index page
  #   Given I am signed in
  #   When I visit the candidate index page
  #   Then I see my own email address
  scenario 'candidate sees own email address' do
    candidate = FactoryGirl.create(:candidate)
    admin = FactoryGirl.create(:admin)
    login_as(admin, scope: :admin)
    visit candidates_path
    expect(page).to have_content candidate.parent_email_1
  end

end
