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

  scenario 'admin can get list of candidates' do
    candidate = FactoryGirl.create(:candidate)
    admin = FactoryGirl.create(:admin)
    login_as(admin, scope: :admin)
    visit candidates_path
    expect(page).to have_content candidate.candidate_sheet.parent_email_1
  end

end
