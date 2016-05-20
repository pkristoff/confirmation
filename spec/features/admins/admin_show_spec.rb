include Warden::Test::Helpers
Warden.test_mode!

# Feature: Admin profile page
#   As a admin
#   I want to visit my admin profile page
#   So I can see my personal account data
feature 'Admin profile page', :devise do

  after(:each) do
    Warden.test_reset!
  end

  # Scenario: Admin sees own profile
  #   Given I am signed in
  #   When I visit the admin profile page
  #   Then I see my own email address
  scenario 'admin sees own profile' do
    admin = FactoryGirl.create(:admin)
    login_as(admin, :scope => :admin)
    visit admin_path(admin)
    expect(page).to have_content 'Admin'
    expect(page).to have_content admin.email
  end

  # Scenario: Admin cannot see another admin's profile
  #   Given I am signed in
  #   When I visit another admin's profile
  #   Then I see an 'access denied' message
  scenario "admin cannot see another admin's profile" do
    me = FactoryGirl.create(:admin)
    other = FactoryGirl.create(:admin, name: 'other', email: 'other@example.com')
    login_as(me, :scope => :admin)
    Capybara.current_session.driver.header 'Referer', root_path
    visit admin_path(other)
    expect(page).to have_selector('div[id=flash_alert]', text: 'Access denied.')
  end

end
