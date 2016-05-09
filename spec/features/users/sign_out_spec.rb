# Feature: Sign out
#   As a candidate
#   I want to sign out
#   So I can protect my account from unauthorized access
feature 'Sign out', :devise do

  # Scenario: Candidate signs out successfully
  #   Given I am signed in
  #   When I sign out
  #   Then I see a signed out message
  scenario 'candidate signs out successfully' do
    candidate = FactoryGirl.create(:candidate)
    signin_candidate(candidate.email, candidate.password)
    expect(page).to have_content I18n.t 'devise.sessions.signed_in'
    click_link 'Sign out'
    expect(page).to have_content I18n.t 'devise.sessions.signed_out'
  end

end


