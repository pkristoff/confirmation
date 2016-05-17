include Warden::Test::Helpers
Warden.test_mode!

# Feature: Candidate edit
#   As a candidate
#   I want to edit my candidate profile
#   So I can change my email address
feature 'Candidate edit', :devise do

  before(:each) do
    @admin = FactoryGirl.create(:admin)
    login_as(@admin, scope: :admin)
  end

  after(:each) do
    Warden.test_reset!
  end

  # Scenario: Candidate changes email address
  #   Given I am signed in
  #   When I change my email address
  #   Then I see an account updated message
  scenario 'candidate changes email address' do
    candidate = FactoryGirl.create(:candidate)
    visit edit_candidate_path(candidate.id) # views/candidates/edit.html.erb
    # /candidates/1 - put: candidate_path(resource)
    fill_in 'Parent email 1', :with => 'newemail@example.com'
    click_button 'Update'
    expect(page).to have_selector('div[id=flash_notice]', text: 'Candidate sophiaagusta updated successfully')
  end

end
