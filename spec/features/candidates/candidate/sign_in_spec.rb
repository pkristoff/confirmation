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
    candidate1 = create_candidate_old('Vicki', 'Anne', 'Kristoff')
    signin_candidate(candidate1.account_name, candidate1.password)
    expect_no_orphaned_associations
  end
  scenario 'candidate forgot password, tries to reset it, but gives wrong account name' do
    AppFactory.add_confirmation_events
    visit new_candidate_session_path
    click_link 'Forgot your password?'
    expect_field('Account name', '')

    fill_in('Account name', with: 'xxx')
    click_button('Reset Password')

    # rubocop:disable Layout/LineLength
    expect_messages([[:flash_alert, 'Account name (xxx) not found. If you are having problems please contact replace me - contact'],
                     [:error_explanation, ['1 error prohibited reset password from being sent:',
                                           'Account name was not found: xxx']]])
    # rubocop:enable Layout/LineLength
  end

  # Scenario: Candidate can't login decides to 'Resend confirmation instructions'
  # but puts in wrong email
  scenario 'Resend confirmation instructions: wrong email' do
    AppFactory.add_confirmation_events
    visit new_candidate_session_path
    expect(page.html).to have_selector('a[href="/dev/candidates/confirmation/new"]',
                                       text: 'Resend confirmation instructions?')
    expect(page.html).to have_selector('a[href="/dev/candidates/password/new"]',
                                       text: 'Forgot your password?')
    click_link 'Resend confirmation instructions?'
    expect(page.html).to have_selector('a[href="/dev/candidates/confirmation/new"]', text: 'Resend confirmation instructions')
    expect_field('Email', '')
    fill_in('Email', with: 'aaa@bbb.com')
    click_button('Resend confirmation instructions')
    expect_messages([
                      [:flash_alert, 'email not associated candidate']
                    ])
  end

  # Scenario: Candidate can't login decides to 'Resend confirmation instructions'
  # puts in right email
  scenario 'Resend confirmation instructions: good email' do
    AppFactory.add_confirmation_events
    create_candidate('c1', { should_confirm: false })
    # need admin contact info even though candidate is logged in
    FactoryBot.create(:admin)

    visit new_candidate_session_path
    click_link 'Resend confirmation instructions?'
    expect(page.html).to have_selector('a[href="/dev/candidates/confirmation/new"]', text: 'Resend confirmation instructions')
    fill_in('Email', with: 'c3last_name.c3first_name@test.com')
    click_button('Resend confirmation instructions')

    expect_messages([
                      [:flash_notice, I18n.t('messages.confirmation_email_sent')]
                    ])
  end

  def create_candidate_old(account_name, first, last)
    candidate = FactoryBot.create(:candidate, account_name: account_name, add_new_confirmation_events: false)
    candidate.candidate_sheet.first_name = first
    candidate.candidate_sheet.last_name = last
    candidate.save
    candidate
  end

  def create_candidate(prefix, should_confirm: true)
    candidate = FactoryBot.create(:candidate, account_name: prefix, should_confirm: should_confirm)
    candidate_event = candidate.add_candidate_event(@confirmation_event)
    case prefix
    when 'c1'
      candidate.candidate_sheet.first_name = 'c2first_name'
      candidate.candidate_sheet.middle_name = 'c1middle_name'
      candidate.candidate_sheet.last_name = 'c3last_name'
      candidate.candidate_sheet.candidate_email = 'c3last_name.c3first_name@test.com'
      candidate_event.completed_date = '2016-06-09'
    else
      throw RuntimeError.new('Unknown prefix')
    end
    candidate.save
    candidate
  end

  def expect_no_orphaned_associations
    orphaneds = Orphaneds.new
    orphaneds.add_orphaned_table_rows
    orphaned_table_rows = orphaneds.orphaned_table_rows
    orphaned_table_rows.each do |key, orphan_ids|
      expect(orphan_ids).to be_empty, "#{key} has orphans"
    end
  end
end
