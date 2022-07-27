# frozen_string_literal: true

Warden.test_mode!

# Feature: Admin index page
#   As a admin
#   I want to see a list of admins
#   So I can see who has registered
feature 'Admin events page', :devise do
  include Warden::Test::Helpers

  before do
    FactoryBot.create(:visitor)
  end

  after(:each) do
    Warden.test_reset!
  end

  scenario 'admin list of no events' do
    admin = FactoryBot.create(:admin)
    login_as(admin, scope: :admin)
    visit edit_multiple_confirmation_events_path

    expect_form
  end

  scenario 'admin list of 1 events' do
    AppFactory.add_confirmation_event(Candidate.covenant_agreement_event_key)
    admin = FactoryBot.create(:admin)
    login_as(admin, scope: :admin)
    visit edit_multiple_confirmation_events_path

    expect_form
  end

  scenario 'admin list of 2 events' do
    agreement_event = AppFactory.add_confirmation_event(Candidate.covenant_agreement_event_key)
    info_event = AppFactory.add_confirmation_event(CandidateSheet.event_key)
    info_event.chs_due_date = '2016-10-29'
    info_event.the_way_due_date = '2016-10-02'
    info_event.instructions = '<p>CIS instructions</p>'
    info_event.save

    admin = FactoryBot.create(:admin)
    login_as(admin, scope: :admin)

    visit edit_multiple_confirmation_events_path

    expect_form

    within_fieldset I18n.t('events.candidate_covenant_agreement') do
      expected_msg = "input[id=confirmation_events_#{agreement_event.id}_the_way_due_date][value='#{Time.zone.today}']"
      expect(page).to have_selector(expected_msg)
      expected_msg = "input[id=confirmation_events_#{agreement_event.id}_chs_due_date][value='#{Time.zone.today}']"
      expect(page).to have_selector(expected_msg)
      expect(page).to have_field(I18n.t('label.events.instructions'), text: '')
    end
    within_fieldset I18n.t('events.candidate_information_sheet') do
      expect(page).to have_selector("input[id=confirmation_events_#{info_event.id}_the_way_due_date][value='2016-10-02']")
      expect(page).to have_selector("input[id=confirmation_events_#{info_event.id}_chs_due_date][value='2016-10-29']")
      expect(page).to have_field(I18n.t('label.events.instructions'), text: '<p>CIS instructions</p>')
    end
  end

  private

  def expect_form
    expect(page).to have_selector('form[action="/update_multiple_confirmation_events?method=put"]', count: 1)
  end
end
