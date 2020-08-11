# frozen_string_literal: true

describe 'Check Events' do
  include ViewsHelpers
  include Warden::Test::Helpers

  before(:each) do
    @missing_events = MissingEvents.new
  end

  after(:each) do
    Warden.test_reset!
  end
  # Scenario: Admin sees confirmation events that are missing, unknown, & found
  #   Given Admin is signed in
  #   When I visit the Other page
  #   and click the click 'Check Event' button
  #   Then I see confirmation events that are missing, unknown, & found
  scenario 'admin can see if confirmation event is missing' do
    setup_unknown_missing_events

    admin = FactoryBot.create(:admin)
    login_as(admin, scope: :admin)
    visit missing_events_check_path

    expected_msg = 'section[id=check_missing_events] form[id=new_missing_events][action="/missing_events/check"]'
    expect(page.html).to have_selector(expected_msg)
    expect(page.html).to have_button(I18n.t('views.missing_events.check'))

    expect(page.html).to have_selector('ul[id=missing_confirmation_events] li', count: 1)
    expect(page.html).to have_selector('ul[id=found_confirmation_events] li', count: 8)
    expect(page.html).to have_selector('ul[id=unknown_confirmation_events] li', count: 1)
    expect(page.html).to have_selector('section[id=check_missing_events] ul', count: 3)
    expect(page.html).to have_selector('section[id=check_missing_events] li', count: 10)

    click_button I18n.t('views.missing_events.check')
    expect(page.html).to have_selector(expected_msg)
    expect(page.html).to have_button(I18n.t('views.missing_events.check'))

    expect(page.html).to have_selector('section[id=check_missing_events] ul[id=missing_confirmation_events] li',
                                       text: I18n.t('events.sponsor_covenant'))
    expect(page.html).to have_selector('section[id=check_missing_events] ul[id=found_confirmation_events] li', count: 8)
    expect(page.html).to have_selector('section[id=check_missing_events] ul[id=unknown_confirmation_events] li',
                                       text: 'unknown event')
  end

  # Scenario: Admin wants to add missing events back into the DB but has not pushed 'Check Events'
  #   Given Admin is signed in
  #   When I visit the Other page
  #   and click the click 'Add Missing Events' button
  #   Then I see message saying to 'Check Events' first
  scenario 'admin gets message saying no missing events' do
    setup_unknown_missing_events

    admin = FactoryBot.create(:admin)
    login_as(admin, scope: :admin)
    visit missing_events_check_path

    click_button I18n.t('views.missing_events.add_missing')

    expect_message(:flash_notice, I18n.t('views.missing_events.added_missing'))
  end

  # Scenario: Admin wants to add missing events back into the DB
  #   Given Admin is signed in
  #   When I visit the Other page
  #   and click the click 'Check Events' button
  #   and click the click 'Add Missing Events' button
  #   Then I see missing event is now in the found events.
  scenario 'admin gets message saying no missing events' do
    setup_unknown_missing_events

    admin = FactoryBot.create(:admin)
    login_as(admin, scope: :admin)
    visit missing_events_check_path

    click_button I18n.t('views.missing_events.check')

    click_button I18n.t('views.missing_events.add_missing')

    expect(page.html).to have_selector('section[id=check_missing_events] ul[id=missing_confirmation_events] li',
                                       count: 0)
    expect(page.html).to have_selector('section[id=check_missing_events] ul[id=found_confirmation_events] li',
                                       count: 9)
    expect(page.html).to have_selector('section[id=check_missing_events] ul[id=unknown_confirmation_events] li',
                                       text: 'unknown event')
  end
end
