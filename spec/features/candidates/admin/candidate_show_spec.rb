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

  # Scenario: Admin sees candide profile
  #   Given Admin is signed in
  #   When I visit the candidate profile page
  #   Then I see candidate_id
  scenario 'candidate sees own profile' do
    admin = FactoryGirl.create(:admin)
    candidate = FactoryGirl.create(:candidate)
    candidate2 = FactoryGirl.create(:candidate, candidate_id: 'other')
    login_as(admin, scope: :admin)
    visit candidate_path(candidate)
    expect(page).to have_content 'Candidate'
    expect(page).to have_content candidate.candidate_id
    visit candidate_path(candidate2)
    expect(page).to have_content 'Candidate'
    expect(page).to have_content candidate2.candidate_id
  end

end
