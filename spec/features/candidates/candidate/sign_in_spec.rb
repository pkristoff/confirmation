# Feature: Sign in
#   As a candidate
#   I want to sign in
#   So I can visit protected areas of the site
feature 'Sign in', :devise do

  # Scenario: Candidate cannot sign in if not registered
  #   Given I do not exist as a candidate
  #   When I sign in with valid credentials
  #   Then I see an invalid credentials message
  scenario 'candidate cannot sign in if not registered' do
    signin_candidate('test@example.com', 'please123')
    expect(page).to have_selector('div[id=flash_alert]', text: I18n.t('devise.failure.not_found_in_database', authentication_keys: 'candidate_id'))
  end

  # Scenario: Candidate can sign in with valid credentials
  #   Given I exist as a candidate
  #   And I am not signed in
  #   When I sign in with valid credentials
  #   Then I see a success message
  scenario 'candidate can sign in with valid credentials' do
    candidate = FactoryGirl.create(:candidate)
    signin_candidate(candidate.candidate_id, candidate.password)
    expect(page).to have_selector('div[id=flash_notice]', text: I18n.t('devise.sessions.signed_in'))
  end

  # Scenario: Candidate cannot sign in with wrong email
  #   Given I exist as a candidate
  #   And I am not signed in
  #   When I sign in with a wrong email
  #   Then I see an invalid email message
  scenario 'candidate cannot sign in with wrong email' do
    candidate = FactoryGirl.create(:candidate)
    signin_candidate('invalid@email.com', candidate.password)
    expect(page).to have_selector('div[id=flash_alert]', text: I18n.t('devise.failure.not_found_in_database', authentication_keys: 'candidate_id'))
  end

  # Scenario: Candidate cannot sign in with wrong password
  #   Given I exist as a candidate
  #   And I am not signed in
  #   When I sign in with a wrong password
  #   Then I see an invalid password message
  scenario 'candidate cannot sign in with wrong password' do
    candidate = FactoryGirl.create(:candidate)
    signin_candidate(candidate.parent_email_1, 'invalidpass')
    expect(page).to have_selector('div[id=flash_alert]', text: I18n.t('devise.failure.not_found_in_database', authentication_keys: 'candidate_id'))
  end

end
