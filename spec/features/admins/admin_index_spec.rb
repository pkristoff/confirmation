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

    expect(page).to have_selector('tr', count: 1)
    expect_admin(admin)
  end

  private

  def expect_admin(admin)
    expect(page).to have_link("delete_#{admin.id}", text: 'Delete')
    expect(page).to have_link("edit_#{admin.id}", text: admin.name)
    expect(page).to have_selector("td[id='email_#{admin.id}']", text: admin.email)
  end
end
