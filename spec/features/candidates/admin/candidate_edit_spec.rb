# frozen_string_literal: true

Warden.test_mode!

# Feature: Candidate edit
#   As a candidate
#   I want to edit my candidate profile
#   So I can change my email address
describe 'Candidate edit', :devise do
  include Warden::Test::Helpers

  before do
    AppFactory.generate_default_status
    FactoryBot.create(:visitor)
    @admin = FactoryBot.create(:admin)
    login_as(@admin, scope: :admin)
  end

  after do
    Warden.test_reset!
  end

  # it: Candidate changes email address
  #   Given I am signed in
  #   When I change my email address
  #   Then I see an account updated message
  it 'candidate changes email address' do
    candidate = FactoryBot.create(:candidate)
    AppFactory.add_confirmation_events

    visit edit_candidate_path(candidate.id)
    fill_in 'Parent email 1', with: 'newemail@example.com'
    click_button I18n.t('views.common.update')
    expect_message(:flash_notice, I18n.t('messages.candidate_updated', name: 'augustasophia'))
  end
end
