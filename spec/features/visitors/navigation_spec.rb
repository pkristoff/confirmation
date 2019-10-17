# frozen_string_literal: true

# Feature: Navigation links
#   As a visitor
#   I want to see navigation links
#   So I can find home, sign in, or sign up
feature 'Navigation links', :devise do
  # Scenario: View navigation links
  #   Given I am a visitor
  #   When I visit the home page
  #   Then I see "home," "sign in," and "sign up"
  scenario 'view navigation links' do
    Visitor.visitor('St. Mary Magdalene', 'replace me - home', 'replace me - about', 'replace me - contaclt')
    visit root_path
    expect(page).to have_content('Home')
    expect(page).to have_content('Sign in')
    expect(page).not_to have_content('Sign up')
    expect(page).to have_content('Sign in admin')
    expect(page).not_to have_content('Sign up admin')
  end
end
