# frozen_string_literal: true

# Feature: Home page
#   As a visitor
#   I want to visit a home page
#   So I can learn more about the website
describe 'Home page' do
  # it: Visit the home page
  #   Given I am a visitor
  #   When I visit the home page
  #   Then I see "Welcome"
  before do
    @visitor_id = FactoryBot.create(:visitor).id
  end

  it 'a visitor visits the home page' do
    visit root_path

    expect(page).to have_selector('span[class=navbar-toggler-icon]', count: 1)

    expect(page).to have_selector('a', text: I18n.t('views.top_bar.home'))
    expect(page).to have_selector('a', text: I18n.t('views.top_bar.about'))
    expect(page).to have_selector('a', text: I18n.t('views.top_bar.sign_in', name: ''))
    expect(page).to have_selector('a', text: I18n.t('views.top_bar.sign_in', name: 'admin'))
    expect(page).to have_selector('a', text: 'Sign in admin')
    expect(page).to have_selector('a', text: I18n.t('views.top_bar.contact'))
    expect(page).to have_selector('a', text: I18n.t('views.top_bar.aboutApp'))
    expect(page).to have_selector('p', text: 'home text')
  end

  it 'html sanitized and gets embeded into the home page' do
    visitor = Visitor.find_by(id: @visitor_id)
    visitor.home = '<p id="xxx" style="text-align:center"> The rain in spain </p>'
    visitor.save

    visit root_path

    expect(page).to have_selector('p[style="text-align:center;"]', text: 'The rain in spain')
  end
end
