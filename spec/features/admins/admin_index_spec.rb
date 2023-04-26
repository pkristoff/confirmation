# frozen_string_literal: true

Warden.test_mode!

# Feature: Admin index page
#   As a admin
#   I want to see a list of admins
#   So I can see who has registered
describe 'Admin index page', :devise do
  include Warden::Test::Helpers

  before do
    FactoryBot.create(:visitor)
  end

  after do
    Warden.test_reset!
  end

  # it: Admin listed on index page
  #   Given I am signed in
  #   When I visit the admin index page
  #   Then I see my own email address
  it 'admin sees own email address' do
    admin = FactoryBot.create(:admin)
    login_as(admin, scope: :admin)
    visit admins_path

    expect(page).to have_selector('h3', text: 'Admins', count: 1)
    expect_admin(page, admin)
  end

  private

  def expect_admin(page, admin)
    expect(page).to have_selector("tr[id=admin-#{admin.id}]", count: 1)
    expect(page).to have_link("delete-#{admin.id}", text: 'Delete')
    expect(page).to have_link("edit-#{admin.id}", text: admin.name)
    expect(page).to have_selector("td[id='account_name-#{admin.id}']", text: admin.account_name)
    expect(page).to have_selector("td[id='contact_name-#{admin.id}']", text: admin.contact_name)
    expect(page).to have_selector("td[id='contact_phone-#{admin.id}']", text: admin.contact_phone)
    expect(page).to have_selector("td[id='email-#{admin.id}']", text: admin.email)
  end
end
