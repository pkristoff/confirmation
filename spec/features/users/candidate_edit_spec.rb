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
    visit edit_candidate_registration_path(candidate)
    fill_in 'Email', :with => 'newemail@example.com'
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
    other = FactoryGirl.create(:candidate, email: 'other@example.com', name: 'other')
    login_as(me, :scope => :candidate)
    visit edit_candidate_registration_path(other)
    expect(page).to have_content 'Edit Candidate'
    expect(page).to have_field('Email', with: me.email)
  end

end
