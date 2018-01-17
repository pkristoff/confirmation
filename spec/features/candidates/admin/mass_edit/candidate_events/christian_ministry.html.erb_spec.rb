# require_relative "helpers/views_helpers.rb"
include ViewsHelpers

include Warden::Test::Helpers
Warden.test_mode!

feature 'Admin verifies christian ministry from Mass Edit Candidates Event', :devise do

  before(:each) do
    @update_id = 'top-update-verify'
    @path_str = 'christian_ministry_verify'
    @dev = ''

    admin = FactoryBot.create(:admin)
    login_as(admin, :scope => :admin)
    @candidate = FactoryBot.create(:candidate)
    AppFactory.add_confirmation_events
    @candidate = Candidate.find_by_account_name(@candidate.account_name)
    @confirmation_event = ConfirmationEvent.find_by_name(I18n.t('events.christian_ministry'))
  end

  after(:each) do
    Warden.test_reset!
  end

  # Admin opens mass edit candidates event for pick candidate event
  # Admin clicks link for candidate
  # christian ministry editor opens.
  # Admin clicks 'Update and Verify'
  # Admin sees a event validation error with no admin validation
  # editor stays open
  scenario 'admin' do
    visit mass_edit_candidates_event_path(@confirmation_event.id)
    candidate_id = @candidate.id
    expect_mass_edit_candidates_event(@confirmation_event, Candidate.find(candidate_id), nil)

    click_link("cma-#{candidate_id}")
    expect_christian_ministry_form(@candidate, @path_str, @dev, @update_id)

    click_button @update_id

    candidate = Candidate.find(candidate_id)
    expect_christian_ministry_form(candidate, @path_str, @dev, @update_id, saint_name: '',
                                   expect_messages: [[:flash_notice, @updated_failed_verification],
                                                     [:error_explanation, 'Your changes were saved!! 4 empty fields need to be filled in on the form to be verfied: What service can\'t be blank Where service can\'t be blank When service can\'t be blank Helped me can\'t be blank']
    ])
    candidate_event = candidate.get_candidate_event(I18n.t('events.christian_ministry'))
    expect(candidate_event.completed_date).to eq(nil)
    expect(candidate_event.verified).to eq(false)

    # usually admin should not do this
    fill_in('What was the service?', with: 'aaa')
    fill_in('Where did the service take place?', with: 'bbb')
    fill_in('When did you do the service?', with: 'ccc')
    fill_in('This experience helped me by', with: 'ddd')
    click_button @update_id

    candidate = Candidate.find(candidate_id)
    expect_mass_edit_candidates_event(@confirmation_event, candidate, nil)
    candidate_event = candidate.get_candidate_event(@confirmation_event.name)
    expect(candidate_event.completed?)
    expect(candidate_event.completed_date).to eq(Date.today)
    expect(candidate_event.verified).to eq(true)
  end
  # Admin opens mass edit candidates event for pick candidate event
  # Admin clicks link for candidate who is awaiting admin
  # christian ministry editor opens.
  # Admin clicks 'Update and Verify'
  # The mass_edit_candidates_event is opened and candidate has been verified.
  scenario 'admin' do
    completed_date = Date.today - 1
    candidate_id = @candidate.id
    candidate = Candidate.find(candidate_id)
    candidate.christian_ministry.what_service='What'
    candidate.christian_ministry.where_service='Where'
    candidate.christian_ministry.when_service='when'
    candidate.christian_ministry.helped_me='Help'
    candidate_event = candidate.get_candidate_event(@confirmation_event.name)
    candidate_event.completed_date= completed_date
    expect(candidate_event.awaiting_admin?).to be(true)
    candidate.save

    visit mass_edit_candidates_event_path(@confirmation_event.id)
    expect_mass_edit_candidates_event(@confirmation_event, Candidate.find(candidate_id), nil)
    # puts page.html
    click_link("cma-#{candidate_id}")
    # puts page.html
    expect_christian_ministry_form(@candidate, @path_str, @dev, @update_id)

    click_button @update_id

    candidate = Candidate.find(candidate_id)
    candidate_event = candidate.get_candidate_event(@confirmation_event.name)

    expect(candidate_event.completed?).to be(true)
    expect(candidate_event.completed_date).to eq(completed_date)
    expect(candidate_event.verified).to eq(true)
    end

end