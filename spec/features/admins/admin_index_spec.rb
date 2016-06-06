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
    other = FactoryGirl.create(:admin, email: 'other@test.com', name: 'other')
    login_as(admin, scope: :admin)
    visit admins_path

    expect(page).to have_selector('tr', count: 2)
    expect_admin(other)
    expect_admin(admin)
  end

  def expect_admin(admin)
    expect(page).to have_link("delete_#{admin.id}", text: 'Delete')
    expect(page).to have_link("edit_#{admin.id}", text: admin.name)
    expect(page).to have_selector("td[id='email_#{admin.id}']", text: admin.email)
  end

end
