include Warden::Test::Helpers
Warden.test_mode!

# Feature: Candidate delete
#   As a candidate
#   I want to delete my candidate profile
#   So I can close my account
feature 'Candidate delete', :devise do

  after(:each) do
    Warden.test_reset!
  end

  # Scenario: Candidate can delete own account
  #   Given I am signed in
  #   When I delete my account
  #   Then I should see an account deleted message
  scenario 'candidate can delete own account' do
    candidate = FactoryGirl.create(:candidate)
    login_as(candidate, :scope => :candidate)
    visit edit_candidate_registration_path(candidate)
    expect(page).not_to have_content "Cancel my account"
  end

  scenario 'candidate can delete own account' do
    candidate = FactoryGirl.create(:candidate)
    admin = FactoryGirl.create(:admin)
    login_as(admin, scope: :admin)
    visit edit_candidate_path(candidate)
    click_button 'Cancel candidate account'
    expect(page).to have_content "Candidate #{candidate.candidate_id} successfully removed Candidates"
  end

end




