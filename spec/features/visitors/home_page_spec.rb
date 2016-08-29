# Feature: Home page
#   As a visitor
#   I want to visit a home page
#   So I can learn more about the website
feature 'Home page' do

  # Scenario: Visit the home page
  #   Given I am a visitor
  #   When I visit the home page
  #   Then I see "Welcome"
  scenario 'visit the home page' do
    visit root_path

    expect(page).to have_selector("button", text: 'Toggle navigation')

    expect(page).to have_selector("a", text: 'Home')
    expect(page).to have_selector("a", text: 'Sign in')
    expect(page).to have_selector("a", text: 'Sign in admin')

    expect(page).to have_selector("a", text: 'Start Bootstrap')
    expect(page).to have_selector("a", text: 'Dashboard')
    expect(page).to have_selector("a", text: 'Shortcuts')
    expect(page).to have_selector("a", text: 'Overview')
    expect(page).to have_selector("a", text: 'Events')
    expect(page).to have_selector("a", text: 'About')
    expect(page).to have_selector("a", text: 'Services')
    expect(page).to have_selector("a", text: 'Contact')
    expect(page).to have_selector("h1", text: 'Simple Sidebar')
    expect(page).to have_selector("p", text: 'This template has a responsive menu toggling system. The menu will appear collapsed on smaller screens, and will appear non-collapsed on larger screens. When toggled using the button below, the menu will appear/disappear. On small screens, the page content will be pushed off canvas.')
    expect(page).to have_selector("p", text: 'Make sure to keep all page content within the #page-content-wrapper.')
    expect(page).to have_selector("a", text: 'Toggle Menu')
  end

end
