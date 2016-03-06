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
    skip 'works when debugging but not in straight mode - sign in'
    admin = FactoryGirl.create(:admin)
    login_as(admin, :scope => :admin)
    visit edit_admin_registration_path(admin)
    fill_in 'Email', :with => 'newemail@example.com'
    fill_in 'Current password', :with => admin.password
    click_button 'Update'
    txts = [I18n.t( 'devise.registrations.updated'), I18n.t( 'devise.registrations.update_needs_confirmation')]
    expect(page).to have_content(/.*#{txts[0]}.*|.*#{txts[1]}.*/)
  end

  # Scenario: Admin cannot edit another admin's profile
  #   Given I am signed in
  #   When I try to edit another admin's profile
  #   Then I see my own 'edit profile' page
  scenario "admin cannot cannot edit another admin's profile", :me do
    me = FactoryGirl.create(:admin)
    other = FactoryGirl.create(:admin, name: 'other', email: 'other@example.com')
    login_as(me, :scope => :admin)
    visit edit_admin_registration_path(other)
    expect(page).to have_content 'Edit Admin'
    expect(page).to have_field('Email', with: me.email)
  end

end
