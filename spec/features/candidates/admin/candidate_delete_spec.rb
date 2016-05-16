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

  scenario 'candidate can delete own account' do
    candidate = FactoryGirl.create(:candidate)
    admin = FactoryGirl.create(:admin)
    login_as(admin, scope: :admin)
    visit edit_candidate_path(candidate)
    click_button 'Cancel candidate account'
    expect(page).to have_selector('div[id=flash_notice]', text: "Candidate #{candidate.candidate_id} successfully removed")
  end

end




