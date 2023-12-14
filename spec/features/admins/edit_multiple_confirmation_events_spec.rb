# frozen_string_literal: true

Warden.test_mode!

describe 'Admin edit_multiple_confirmation_events', :devise do
  include ViewsHelpers
  include Warden::Test::Helpers

  before do
    FactoryBot.create(:visitor)
    AppFactory.generate_default_status
    @candidate1 = Candidate.find_by(account_name: create_candidate('Vicki', 'Anne', 'Kristoff').account_name)
    @candidate2 = Candidate.find_by(account_name: create_candidate('Paul', 'Richard', 'Kristoff').account_name)
    @candidates = [@candidate1, @candidate2]

    AppFactory.add_confirmation_events
    admin = FactoryBot.create(:admin)
    login_as(admin, scope: :admin)

    @today = Time.zone.today
  end

  after do
    Warden.test_reset!
  end

  it 'admin changes event value hits update' do
    visit edit_multiple_confirmation_events_path

    confirmation_event = ConfirmationEvent.find_by(event_key: PickConfirmationName.event_key)

    the_way_due_date_id = "confirmation_events_#{confirmation_event.id}_the_way_due_date"
    chs_due_date_id = "confirmation_events_#{confirmation_event.id}_chs_due_date"
    instructions_id = "confirmation_events_#{confirmation_event.id}_instructions"

    fill_in the_way_due_date_id, with: @today - 10
    fill_in chs_due_date_id, with: @today - 8
    fill_in instructions_id, with: 'Very important instructions'

    click_button("update-#{confirmation_event.id}")

    expect_message(:flash_notice, I18n.t('messages.confirmation_events_updated'))
    expect(page).to have_css("input[id=#{the_way_due_date_id}][value='#{@today - 10}']")
    expect(page).to have_css("input[id=#{chs_due_date_id}][value='#{@today - 8}']")
    expect(page).to have_css("textarea[id=#{instructions_id}]", text: 'Very important instructions')
  end

  it 'admin clicks the updates candidates events button' do
    candidate = Candidate.find_by(account_name: @candidate1.account_name)
    event_key = PickConfirmationName.event_key
    candidate_event = candidate.get_candidate_event(event_key)
    candidate_event.completed_date = @today
    candidate_event.save

    visit edit_multiple_confirmation_events_path

    click_button("candidates-#{ConfirmationEvent.find_by(event_key: event_key).id}")

    expect(page).to have_css('h2', text: Candidate.i18n_event_name(event_key))
    expect(page).to have_field(I18n.t('views.events.completed_date'))
    expect(page).to have_unchecked_field(I18n.t('views.events.verified'))

    expect_sorting_candidate_list(
      confirmation_events_columns(event_key),
      @candidates,
      page
    )
  end
end
