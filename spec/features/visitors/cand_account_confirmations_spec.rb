# frozen_string_literal: true

# Feature: Home page
#   As a visitor
#   I want to visit a home page
#   So I can learn more about the website
feature 'Home page' do
  before do
    FactoryBot.create(:visitor)
  end
  # Scenario: Visit the home page
  #   Given I am a visitor
  #   When I visit the home page
  #   Then I see "Welcome"
  scenario 'visit the home page' do
    candidate = FactoryBot.create(:candidate, should_confirm: false)
    candidate.save
    FactoryBot.create(:admin)

    visit cand_account_confirmation_url(candidate.id, 'noerrors')

    expect_cand_account_confirmation(candidate.id,
                                     expected_messages: [[:flash_notice, I18n.t('messages.reset_password_message_sent')]])
  end

  private

  def expect_cand_account_confirmation(cand_id, values = {})
    expect_messages(values[:expected_messages]) unless values[:expected_messages].nil?

    candidate = Candidate.find_by(id: cand_id)

    expect(page).to have_selector('p', text: I18n.t('messages.cand_account_is_confirmed', account_name: candidate.account_name))
    expect(page).to have_selector('p', text: I18n.t('messages.cand_account_confirmed_next'))
  end
end
