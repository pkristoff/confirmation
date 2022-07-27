# frozen_string_literal: true

# Feature: Contact page
#   As a visitor
#   I want to visit a contact page via help menu
feature 'Contact page' do
  # Scenario: Visit the contact page
  #   Given I am a visitor
  #   When I visit the contact page
  #   Then I see "Welcome"
  before(:each) do
    @visitor_id = FactoryBot.create(:visitor).id
  end
  scenario 'a visitor visits the home page' do
    visit contact_path

    expect(page).to have_selector('span[class=navbar-toggler-icon]', count: 1)

    expect(page).to have_selector('a', text: I18n.t('views.top_bar.home'))
    expect(page).to have_selector('a', text: I18n.t('views.top_bar.about'))
    expect(page).to have_selector('a', text: I18n.t('views.top_bar.sign_in', name: ''))
    expect(page).to have_selector('a', text: I18n.t('views.top_bar.sign_in', name: 'admin'))
    expect(page).to have_selector('a', text: 'Sign in admin')
    expect(page).to have_selector('a', text: I18n.t('views.top_bar.contact'))
    expect(page).to have_selector('a', text: I18n.t('views.top_bar.aboutApp'))
    expect(page).to have_selector('p', text: 'contact me')
  end

  scenario 'html sanitized and gets embeded into the contact page' do
    visitor = Visitor.find_by(id: @visitor_id)
    # rubocop:disable Layout/LineLength
    visitor.contact = '<a href="mailto:stmm.confirmation@kristoffs.com?subject=Help" id="foo" style="text-align: center;" target="_top">Contact Admin via email stmm.confirmation@kristoffs.com</a>'
    # rubocop:enable Layout/LineLength
    visitor.save

    visit contact_path

    expect(page).to have_selector('a[style="text-align:center;"]',
                                  text: 'Contact Admin via email stmm.confirmation@kristoffs.com')
  end
end
