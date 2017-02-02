include Warden::Test::Helpers
Warden.test_mode!

feature 'Candidate import page', :devise do

  after(:each) do
    Warden.test_reset!
  end

  # Scenario: Admin sees confirmation events that are missing, unknown, & found
  #   Given Admin is signed in
  #   When I visit the Other page
  #   and click the click 'Check Event' button
  #   Then I see confirmation events that are missing, unknown, & found
  scenario 'admin can see if confirmation event is missing' do
    setup_missing_unknow_and_found_events

    admin = FactoryGirl.create(:admin)
    login_as(admin, scope: :admin)
    visit new_candidate_import_path
    expect(page.html).to have_selector('section[id=check_events] form[id=new_candidate_import][action="/candidate_imports/check_events"]')
    expect(page.html).to have_button(I18n.t('views.imports.check_events'))

    expect(page.html).to have_selector('ul[id=missing_confirmation_events]')
    expect(page.html).to have_selector('ul[id=found_confirmation_events]')
    expect(page.html).to have_selector('ul[id=unknown_confirmation_events]')
    expect(page.html).to have_selector('section[id=check_events] ul', count: 3)
    expect(page.html).to have_selector('section[id=check_events] li', count: 0)

    click_button I18n.t('views.imports.check_events')
    expect(page.html).to have_selector('section[id=check_events] form[id=new_candidate_import][action="/candidate_imports/check_events"]')
    expect(page.html).to have_button(I18n.t('views.imports.check_events'))

    expect(page.html).to have_selector('section[id=check_events] ul[id=missing_confirmation_events] li', text: I18n.t('events.sponsor_covenant'))
    expect(page.html).to have_selector('section[id=check_events] ul[id=found_confirmation_events] li', count: 8)
    expect(page.html).to have_selector('section[id=check_events] ul[id=unknown_confirmation_events] li', text: 'unknown event')
  end

  def setup_missing_unknow_and_found_events
    candidate_import = CandidateImport.new
    candidate_import.remove_all_candidates
    AppFactory.all_i18n_confirmation_event_names.each do |i18n_name|
      i18n_confirmation_name = I18n.t(i18n_name)
      AppFactory.add_confirmation_event(i18n_confirmation_name) unless i18n_name == 'events.sponsor_covenant'
    end
    AppFactory.add_confirmation_event('unknown event')
  end

end
