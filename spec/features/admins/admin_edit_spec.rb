include Warden::Test::Helpers
Warden.test_mode!

# Feature: Admin edit
#   As a admin
#   I want to edit my admin profile
#   So I can change my email address
feature 'Admin edit', :devise do

  after(:each) do
    Warden.test_reset!
  end

  # Scenario: Admin changes email address
  #   Given I am signed in
  #   When I change my email address
  #   Then I see an account updated message
  scenario 'admin changes email address' do
    admin = FactoryBot.create(:admin)
    login_as(admin, :scope => :admin)
    visit edit_admin_registration_path(admin)
    fill_in I18n.t('views.admins.email'), :with => 'newemail@example.com'
    fill_in I18n.t('views.admins.current_password'), :with => admin.password
    click_button I18n.t('views.common.update')
    txts = [I18n.t( 'devise.registrations.updated'), I18n.t( 'devise.registrations.update_needs_confirmation')]
    expect_message(:flash_notice, /.*#{txts[0]}.*|.*#{txts[1]}.*/)
  end

  # Scenario: Admin cannot edit another admin's profile
  #   Given I am signed in
  #   When I try to edit another admin's profile
  #   Then I see my own 'edit profile' page
  scenario "admin cannot cannot edit another admin's profile", :me do
    me = FactoryBot.create(:admin)
    other = FactoryBot.create(:admin, name: 'other', email: 'other@example.com')
    login_as(me, :scope => :admin)
    visit edit_admin_registration_path(other)
    expect(page).to have_content 'Edit Admin'
    expect(page).to have_field(I18n.t('views.admins.email'), with: me.email)
  end

end
