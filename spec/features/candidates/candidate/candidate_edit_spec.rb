include Warden::Test::Helpers
Warden.test_mode!

# Feature: Candidate edit
#   As a candidate
#   I want to edit my candidate profile
#   So I can change my email address
feature 'Candidate edit', :devise do

  before(:each) do
    @candidate = FactoryBot.create(:candidate)
    login_as(@candidate, scope: :candidate)
  end

  after(:each) do
    Warden.test_reset!
  end

  # Scenario: Candidate changes email address
  #   Given I am signed in
  #   When I change my email address
  #   Then I see an account updated message
  scenario 'candidate changes email address' do
    visit edit_candidate_registration_path(@candidate.id) # views/candidates/registrations/edit.html.erb
    # /dev/candidates - put registration_path(resource_name)
    fill_in 'Parent email 1', :with => 'newemail@example.com'
    fill_in I18n.t('views.admins.current_password'), :with => @candidate.password
    click_button I18n.t('views.common.update')
    expect_message(:'flash_notice', I18n.t('devise.registrations.updated'))
  end

  # Scenario: Candidate must supply password to make changes
  #   Given I am signed in
  #   When I change my email address without password
  #   Then I see missing password message
  scenario 'candidate changes email address' do
    visit edit_candidate_registration_path(@candidate.id) # views/candidates/registrations/edit.html.erb
    # /dev/candidates - put registration_path(resource_name)
    fill_in 'Parent email 1', :with => 'newemail@example.com'
    click_button I18n.t('views.common.update')
    expect_message(:error_explanation, "#{I18n.t('errors.messages.not_saved.one', resource: :candidate)} Current password can\'t be blank")
  end

  # Scenario: Candidate cannot edit another candidate's profile
  #   Given I am signed in
  #   When I try to edit another candidate's profile
  #   Then I see my own 'edit profile' page
  scenario "candidate try to edit another candidate's profile will end up editing your own", :me do
    other = FactoryBot.create(:candidate, account_name: 'other')
    other.candidate_sheet.parent_email_1 = 'other@test.com'
    visit edit_candidate_registration_path(other.id)
    expect(page).to have_content I18n.t('views.candidates.edit_candidate')
    expect(page).to have_field('Parent email 1', with: @candidate.candidate_sheet.parent_email_1)
  end

end
