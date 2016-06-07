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
    expect(page).to have_content I18n.t('views.admins.admin')
    expect(page).to have_content admin.email
  end

end
