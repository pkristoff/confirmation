# frozen_string_literal: true

# Feature: Home page
#   As a visitor
#   I want to visit a home page
#   So I can learn more about the website
feature 'Home page' do
  # Scenario: Visit the home page
  #   Given I am a visitor
  #   When I visit the home page
  #   Then I see "Welcome"
  before(:each) do
    @visitor_id = Visitor.visitor('St. Mary Magdalene', '<p>home text</p>', 'replace me - about', 'replace me - contaclt').id
  end
  scenario 'a visitor visits the home page' do
    visit root_path

    expect(page).to have_selector('button', text: 'Toggle navigation')

    expect(page).to have_selector('a', text: I18n.t('views.top_bar.home'))
    expect(page).to have_selector('a', text: I18n.t('views.top_bar.about'))
    expect(page).to have_selector('a', text: I18n.t('views.top_bar.sign_in', name: ''))
    expect(page).to have_selector('a', text: I18n.t('views.top_bar.sign_in', name: 'admin'))
    expect(page).to have_selector('a', text: 'Sign in admin')
    expect(page).to have_selector('a', text: I18n.t('views.top_bar.contact_information'))
    expect(page).to have_selector('a', text: I18n.t('views.top_bar.aboutApp'))
    expect(page).to have_selector('p', text: 'home text')
  end

  scenario 'html sanitized and gets embeded into the home page' do
    visitor = Visitor.find_by(id: @visitor_id)
    visitor.home = '<p id="xxx" style="text-align: center"> The rain in spain </p>'
    visitor.save

    visit root_path

    expect(page).to have_selector('p[style="text-align: center;"]', text: 'The rain in spain')
  end
end
