# frozen_string_literal: true

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
    expect_message(:flash_alert, I18n.t('devise.failure.not_found_in_database', authentication_keys: 'Account name'))
  end

  # Scenario: Candidate can sign in with valid credentials
  #   Given I exist as a candidate
  #   And I am not signed in
  #   When I sign in with valid credentials
  #   Then I see a success message
  scenario 'candidate can sign in with valid credentials' do
    candidate = FactoryBot.create(:candidate)
    AppFactory.add_confirmation_events

    signin_candidate(candidate.account_name, candidate.password)

    expect_message(:flash_notice, I18n.t('devise.sessions.signed_in'))
  end

  # Scenario: Candidate cannot sign in with wrong email
  #   Given I exist as a candidate
  #   And I am not signed in
  #   When I sign in with a wrong email
  #   Then I see an invalid email message
  scenario 'candidate cannot sign in with wrong email' do
    candidate = FactoryBot.create(:candidate)
    signin_candidate('invalid@email.com', candidate.password)
    expect_message(:flash_alert, I18n.t('devise.failure.not_found_in_database', authentication_keys: 'Account name'))
  end

  # Scenario: Candidate cannot sign in with wrong password
  #   Given I exist as a candidate
  #   And I am not signed in
  #   When I sign in with a wrong password
  #   Then I see an invalid password message
  scenario 'candidate cannot sign in with wrong password' do
    candidate = FactoryBot.create(:candidate)
    signin_candidate(candidate.candidate_sheet.parent_email_1, 'invalidpass')
    expect_message(:flash_alert, I18n.t('devise.failure.not_found_in_database', authentication_keys: 'Account name'))
  end

  # Scenario: Candidate signing in should not create orphaned associations
  #   Given I exist as a candidate
  #   And I am not signed in
  #   When I sign in
  #   Then orphaned associations should not be created.
  scenario 'candidate cannot sign in with wrong password' do
    AppFactory.add_confirmation_events
    candidate1 = create_candidate('Vicki', 'Anne', 'Kristoff')
    signin_candidate(candidate1.account_name, candidate1.password)
    expect_no_orphaned_associations
  end

  def create_candidate(account_name, first, last)
    candidate = FactoryBot.create(:candidate, account_name: account_name, add_candidate_events: false)
    candidate.candidate_sheet.first_name = first
    candidate.candidate_sheet.last_name = last
    candidate.save
    candidate
  end

  def expect_no_orphaned_associations
    candidate_import = CandidateImport.new
    candidate_import.add_orphaned_table_rows
    orphaned_table_rows = candidate_import.orphaned_table_rows
    orphaned_table_rows.each do |_key, orphan_ids|
      expect(orphan_ids).to be_empty
    end
  end
end
