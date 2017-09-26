include ViewsHelpers
include Warden::Test::Helpers
Warden.test_mode!


feature 'Admin edit_multiple_confirmation_events', :devise do

  before(:each) do

    @candidate_1 = Candidate.find_by_account_name(create_candidate('Vicki', 'Anne', 'Kristoff').account_name)
    @candidate_2 = Candidate.find_by_account_name(create_candidate('Paul', 'Richard', 'Kristoff').account_name)
    @candidates = [@candidate_1, @candidate_2]

    AppFactory.add_confirmation_events
    admin = FactoryGirl.create(:admin)
    login_as(admin, :scope => :admin)
  end

  after(:each) do
    Warden.test_reset!
  end

  scenario 'admin changes event value hits update' do
    visit edit_multiple_confirmation_events_path

    confirmation_event = ConfirmationEvent.find_by_name(I18n.t('events.confirmation_name'))


    the_way_due_date_id = "confirmation_events_#{confirmation_event.id}_the_way_due_date"
    chs_due_date_id = "confirmation_events_#{confirmation_event.id}_chs_due_date"
    instructions_id = "confirmation_events_#{confirmation_event.id}_instructions"

    fill_in the_way_due_date_id, with: Date.today-10
    fill_in chs_due_date_id, with: Date.today-8
    fill_in instructions_id, with: 'Very important instructions'

    click_button("update-#{confirmation_event.id}")

    expect_message(:flash_notice, I18n.t('messages.confirmation_events_updated'))
    expect(page).to have_css("input[id=#{the_way_due_date_id}][value='#{(Date.today-10).to_s}']")
    expect(page).to have_css("input[id=#{chs_due_date_id}][value='#{(Date.today-8).to_s}']")
    expect(page).to have_css("textarea[id=#{instructions_id}]", text: 'Very important instructions')

  end

  scenario 'admin clicks the updates candidates events button' do

    candidate = (Candidate.find_by_account_name(@candidate_1.account_name))
    event_name = I18n.t('events.confirmation_name')
    candidate_event = candidate.get_candidate_event(event_name)
    candidate_event.completed_date = Date.today
    candidate_event.save

    visit edit_multiple_confirmation_events_path

    click_button("candidates-#{ConfirmationEvent.find_by_name(event_name).id}")

    expect(page).to have_css('h2', text: event_name)
    expect(page).to have_field(I18n.t('views.events.completed_date'))
    expect(page).to have_unchecked_field(I18n.t('views.events.verified'))


    columns_in_order = get_columns_helpers
    columns_in_order.insert(
        1,
        [I18n.t('views.events.completed_date'), true, [:candidate_event, event_name, :completed_date]],
        [I18n.t('views.events.verified'), true, [:candidate_event, event_name, :verified]]
    )
    expect_sorting_candidate_list(
        columns_in_order,
        @candidates,
        page)

  end

end




