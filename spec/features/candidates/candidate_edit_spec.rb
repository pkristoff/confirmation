include Warden::Test::Helpers
Warden.test_mode!

# Feature: Candidate edit
#   As a candidate
#   I want to edit my candidate profile
#   So I can change my email address
feature 'Candidate edit', :devise do

  after(:each) do
    Warden.test_reset!
  end

  # Scenario: Candidate changes email address
  #   Given I am signed in
  #   When I change my email address
  #   Then I see an account updated message
  scenario 'candidate changes email address' do
    candidate = FactoryGirl.create(:candidate)
    login_as(candidate, :scope => :candidate)
    visit edit_candidate_path(candidate.id)
    fill_in 'Parent email 1', :with => 'newemail@example.com'
    fill_in 'Current password', :with => candidate.password
    click_button 'Update'
    txts = [I18n.t( 'devise.registrations.updated'), I18n.t( 'devise.registrations.update_needs_confirmation')]
    expect(page).to have_content(/.*#{txts[0]}.*|.*#{txts[1]}.*/)
  end

  # Scenario: Candidate cannot edit another candidate's profile
  #   Given I am signed in
  #   When I try to edit another candidate's profile
  #   Then I see my own 'edit profile' page
  scenario "candidate cannot cannot edit another candidate's profile", :me do
    me = FactoryGirl.create(:candidate)
    other = FactoryGirl.create(:candidate, candidate_id: 'other', parent_email_1: 'other@test.com')
    login_as(me, :scope => :candidate)
    visit edit_candidate_path(other.id)
    expect(page).to have_content 'Edit Candidate'
    expect(page).to have_field('Parent email 1', with: other.parent_email_1)
  end

end
