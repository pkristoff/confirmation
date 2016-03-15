include Warden::Test::Helpers
Warden.test_mode!

# Feature: Admin edit
#   As a admin
#   I want to edit my admin profile
#   So I can change my email address
feature 'Admin sign up', :devise do

  after(:each) do
    Warden.test_reset!
  end

  # Scenario: Admin  can sign up another admin
  #   Given I am signed in as admin
  #   When i click admin sign up
  #   Then I am not blocked because i am logged in
  scenario 'admin can sign up another admin' do
    admin = FactoryGirl.create(:admin)
    login_as(admin, :scope => :admin)
    visit new_admin_registration_path # click Sign up admin
    expect(page).to have_content('Name')
    expect(page).to have_content(/Sign up/)
  end

  # Scenario: admin can create another admin
  #   Given I am signed in (me)
  #   admin clicks admin sign up
  #   admin fills in fields
  #   Then I see list of admins including me & new admin
  scenario "admin can create another admin", :me do
    me = FactoryGirl.create(:admin)
    login_as(me, :scope => :admin)
    visit new_admin_registration_path # click Sign up admin
    fill_in 'Name', :with => 'otherName'
    fill_in 'Email', :with => 'otheremail@example.com'
    fill_in 'Password', :with => 'abcdefgh'
    fill_in 'Password confirmation', :with => 'abcdefgh'
    click_button 'Sign up'

    expect(page).to have_content('Admin User')
    expect(page).to have_content('test@example.com')

    expect(page).to have_content('otherName')
    expect(page).to have_content('otheremail@example.com')
  end

end
