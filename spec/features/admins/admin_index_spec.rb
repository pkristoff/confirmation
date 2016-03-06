include Warden::Test::Helpers
Warden.test_mode!

# Feature: Admin index page
#   As a admin
#   I want to see a list of admins
#   So I can see who has registered
feature 'Admin index page', :devise do

  after(:each) do
    Warden.test_reset!
  end

  # Scenario: Admin listed on index page
  #   Given I am signed in
  #   When I visit the admin index page
  #   Then I see my own email address
  scenario 'admin sees own email address' do
    admin = FactoryGirl.create(:admin)
    login_as(admin, scope: :admin)
    visit admins_path
    expect(page).to have_content admin.email
  end

end
