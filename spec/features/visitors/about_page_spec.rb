# frozen_string_literal: true

# Feature: About page
#   As a visitor
#   I want to visit about page
#   So I can learn more about the website
describe 'About page' do
  before do
    @visitor_id = FactoryBot.create(:visitor).id
  end

  # it: Visit the about page
  #   Given I am a visitor
  #   When I visit the about page
  #   Then I see "about text"
  it 'a visitor visits the about page' do
    visit about_path

    expect(page).to have_selector('span[class=navbar-toggler-icon]', count: 1)

    expect(page).to have_selector('a', text: I18n.t('views.top_bar.home'))
    expect(page).to have_selector('a', text: I18n.t('views.top_bar.about'))
    expect(page).to have_selector('a', text: I18n.t('views.top_bar.sign_in', name: ''))
    expect(page).to have_selector('a', text: I18n.t('views.top_bar.sign_in', name: 'admin'))
    expect(page).to have_selector('a', text: 'Sign in admin')
    expect(page).to have_selector('a', text: I18n.t('views.top_bar.contact'))
    expect(page).to have_selector('a', text: I18n.t('views.top_bar.aboutApp'))
    expect(page).to have_selector('p', text: 'about text')
  end

  it 'html sanitized and gets embeded into the about page' do
    visitor = Visitor.find_by(id: @visitor_id)
    visitor.about = '<p id="xxx" style="text-align:center"> The rain in spain </p>'
    visitor.save

    visit about_path

    expect(page).to have_selector('p[style="text-align:center;"]', text: 'The rain in spain')
  end
end
