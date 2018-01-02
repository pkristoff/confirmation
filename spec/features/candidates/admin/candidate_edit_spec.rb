include Warden::Test::Helpers
Warden.test_mode!

# Feature: Candidate edit
#   As a candidate
#   I want to edit my candidate profile
#   So I can change my email address
feature 'Candidate edit', :devise do

  before(:each) do
    @admin = FactoryBot.create(:admin)
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
    candidate = FactoryBot.create(:candidate)
    AppFactory.add_confirmation_events

    visit edit_candidate_path(candidate.id)
    fill_in 'Parent email 1', :with => 'newemail@example.com'
    click_button I18n.t('views.common.update')
    expect_message(:flash_notice, I18n.t('messages.candidate_updated', name: 'sophiaagusta'))

  end

end
