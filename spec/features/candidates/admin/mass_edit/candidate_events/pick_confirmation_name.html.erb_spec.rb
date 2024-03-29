# frozen_string_literal: true

describe 'Admin verifies Pick confirmation name from Mass Edit Candidates Event', :devise do
  include ViewsHelpers

  include Warden::Test::Helpers
  Warden.test_mode!

  before do
    AppFactory.generate_default_status
    FactoryBot.create(:visitor)
    @update_id = 'top-update-verify'
    @path_str = 'pick_confirmation_name_verify'
    @dev = ''

    admin = FactoryBot.create(:admin)
    login_as(admin, scope: :admin)
    candidate = FactoryBot.create(:candidate)
    AppFactory.add_confirmation_events
    @cand_id = candidate.id
    @confirmation_event = ConfirmationEvent.find_by(event_key: PickConfirmationName.event_key)
  end

  after do
    Warden.test_reset!
  end

  # Admin opens mass edit candidates event for pick candidate event
  # Admin clicks link for candidate
  # Pick confirmation name editor opens.
  # Admin clicks 'Update and Verify'
  # Admin sees a event validation error with no admin validation
  # editor stays open
  it 'admin' do
    visit mass_edit_candidates_event_path(@confirmation_event.id)

    expect_mass_edit_candidates_event(@confirmation_event, @cand_id, nil)

    click_link("pick-#{@cand_id}")
    expect_pick_confirmation_name_form(@cand_id, @path_str, @dev, @update_id, @is_verify)

    click_button @update_id

    candidate = Candidate.find(@cand_id)
    error_msg = I18n.t('messages.error.missing_attribute')
    expect_pick_confirmation_name_form(@cand_id, @path_str, @dev, @update_id, @is_verify,
                                       saint_name: '',
                                       expected_messages: [
                                         [:flash_notice, @updated_failed_verification],
                                         [:error_explanation,
                                          [error_msg,
                                           I18n.t('errors.format_blank',
                                                  attribute:
                                                    I18n.t('activerecord.attributes.pick_confirmation_name.saint_name'))]]
                                       ])
    candidate_event = candidate.get_candidate_event(PickConfirmationName.event_key)
    expect(candidate_event.completed_date).to be_nil
    expect(candidate_event.verified).to be(false)

    # usually admin should not do this
    fill_in(I18n.t('activerecord.attributes.pick_confirmation_name.saint_name'), with: 'St. Admin')
    click_button @update_id

    candidate = Candidate.find(@cand_id)
    expect_mass_edit_candidates_event(@confirmation_event, candidate.id, nil)
    candidate_event = candidate.get_candidate_event(@confirmation_event.event_key)
    expect(candidate_event.completed?).to be(true)
    expect(candidate_event.completed_date).to eq(Time.zone.today)
    expect(candidate_event.verified).to be(true)
  end

  # Admin opens mass edit candidates event for pick candidate event
  # Admin clicks link for candidate who is awaiting admin
  # Pick confirmation name editor opens.
  # Admin clicks 'Update and Verify'
  # The mass_edit_candidates_event is opened and candidate has been verified.
  it 'admin - 2' do
    completed_date = Time.zone.today - 1
    candidate = Candidate.find(@cand_id)
    candidate.pick_confirmation_name.saint_name = 'Paul'
    candidate_event = candidate.get_candidate_event(@confirmation_event.event_key)
    candidate_event.completed_date = completed_date
    expect(candidate_event.awaiting_admin?).to be(true)
    candidate.save

    visit mass_edit_candidates_event_path(@confirmation_event.id)
    expect_mass_edit_candidates_event(@confirmation_event, @cand_id, nil)

    click_link("pick-#{@cand_id}")

    expect_pick_confirmation_name_form(@cand_id, @path_str, @dev, @update_id, @is_verify)

    click_button @update_id

    candidate = Candidate.find(@cand_id)
    candidate_event = candidate.get_candidate_event(@confirmation_event.event_key)

    expect(candidate_event.completed?).to be(true)
    expect(candidate_event.completed_date).to eq(completed_date)
    expect(candidate_event.verified).to be(true)
  end
end
