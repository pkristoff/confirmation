include Warden::Test::Helpers
Warden.test_mode!

# Feature: Admin index page
#   As a admin
#   I want to see a list of admins
#   So I can see who has registered
feature 'Admin events page', :devise do

  after(:each) do
    Warden.test_reset!
  end

  scenario 'admin list of no events' do
    admin = FactoryGirl.create(:admin)
    login_as(admin, scope: :admin)
    visit edit_multiple_confirmation_events_path

    expect_form
  end

  scenario 'admin list of 1 events' do
    AppFactory.add_confirmation_event(I18n.t('events.candidate_covenant_agreement'))
    admin = FactoryGirl.create(:admin)
    login_as(admin, scope: :admin)
    visit edit_multiple_confirmation_events_path

    expect_form
  end

  scenario 'admin list of 2 events' do
    agreement_event = AppFactory.add_confirmation_event(I18n.t('events.candidate_covenant_agreement'))
    info_event = AppFactory.add_confirmation_event(I18n.t('events.candidate_information_sheet'))
    info_event.chs_due_date = '2016-10-29'
    info_event.the_way_due_date = '2016-10-02'
    info_event.instructions = '<p>CIS instructions</p>'
    info_event.save

    admin = FactoryGirl.create(:admin)
    login_as(admin, scope: :admin)

    visit edit_multiple_confirmation_events_path

    expect_form

    within_fieldset I18n.t('events.candidate_covenant_agreement') do
      expect(page).not_to have_field(I18n.t('label.events.name'))
      expect(page).to have_selector("input[id=confirmation_events_#{agreement_event.id}_the_way_due_date][value='#{Date.today.to_s}']")
      expect(page).to have_selector("input[id=confirmation_events_#{agreement_event.id}_chs_due_date][value='#{Date.today.to_s}']")
      expect(page).to have_field(I18n.t('label.events.instructions'), text: '')
    end
    within_fieldset I18n.t('events.candidate_information_sheet') do
      expect(page).not_to have_field(I18n.t('label.events.name'))
      expect(page).to have_selector("input[id=confirmation_events_#{info_event.id}_the_way_due_date][value='2016-10-02']")
      expect(page).to have_selector("input[id=confirmation_events_#{info_event.id}_chs_due_date][value='2016-10-29']")
      expect(page).to have_field(I18n.t('label.events.instructions'), text: '<p>CIS instructions</p>')
    end
  end

  def expect_form
    expect(page).to have_selector('form[action="/update_multiple_confirmation_events?method=put"]', count: 1)
  end

end
