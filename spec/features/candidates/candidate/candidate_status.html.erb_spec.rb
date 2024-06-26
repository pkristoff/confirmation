# frozen_string_literal: true

Warden.test_mode!

describe 'Candidate status', :devise do
  include Warden::Test::Helpers

  before do
    AppFactory.generate_default_status
    FactoryBot.create(:visitor)
    @cand_id = FactoryBot.create(:candidate).id
    admin = FactoryBot.create(:admin)
    login_as(admin, scope: :admin)

    @path = candidate_status_path(@cand_id)

    @path_str = 'status'
    @update_id = 'top-update'
    cand_name = 'Sophia Augusta'
    @updated_message = I18n.t('messages.updated', cand_name: cand_name)
    @updated_failed_verification = I18n.t('messages.updated', cand_name: cand_name)
    @is_verify = false
  end

  after do
    Warden.test_reset!
  end

  it 'admin logs in, edits candidate status' do
    cand = Candidate.find(@cand_id)
    cand.candidate_sheet.candidate_email = 'm'
    cand.save(validate: false)

    visit @path

    expect_candidate_status_form(@cand_id, @path_str, @update_id, { expected_selection: Status::ACTIVE })
  end

  it 'admin logs in, selects candidate status, changes it to DEFERRED and saves' do
    visit @path
    expect(Status.count).to be(4)

    select Status::DEFERRED,
           from: I18n.t('activerecord.attributes.candidate.status_id')

    click_button @update_id

    expect_candidate_status_form(@cand_id,
                                 @path_str,
                                 @update_id,
                                 {
                                   expected_selection: 'Deferred',
                                   expected_messages: [[:flash_notice, @updated_message]]
                                 })
  end

  it 'admin logs in, selects candidate status, changes it to CONFIRMED_ELSEWHERE and saves' do
    visit @path
    expect(Status.count).to be(4)

    select Status::CONFIRMED_ELSEWHERE,
           from: I18n.t('activerecord.attributes.candidate.status_id')

    click_button @update_id

    expect_candidate_status_form(@cand_id,
                                 @path_str,
                                 @update_id,
                                 {
                                   expected_selection: Status::CONFIRMED_ELSEWHERE,
                                   expected_messages: [[:flash_notice, @updated_message]]
                                 })
  end

  it 'admin logs in, selects candidate status, changes it to FROM_ANOTHER_PARISH and saves' do
    visit @path
    expect(Status.count).to be(4)

    select Status::FROM_ANOTHER_PARISH,
           from: I18n.t('activerecord.attributes.candidate.status_id')

    click_button @update_id

    expect_candidate_status_form(@cand_id,
                                 @path_str,
                                 @update_id,
                                 {
                                   expected_selection: Status::FROM_ANOTHER_PARISH,
                                   expected_messages: [[:flash_notice, @updated_message]]
                                 })
  end

  private

  def expect_candidate_status_form(cand_id, path_str, update_id, values = {})
    cand = Candidate.find(cand_id)
    expect_messages(values[:expected_messages]) unless values[:expecteded_messages].nil?
    expected_selection = values[:expected_selection].nil? ? nil : values[:expected_selection]

    expect_heading(cand, I18n.t('activerecord.attributes.candidate.status_id'))

    expect(page).to have_selector("form[id=\"edit_candidate\"][action=\"/#{path_str}.#{cand_id}\"]")

    expect(page).to have_select(
      I18n.t('activerecord.attributes.candidate.status_id'), # locator
      selected: expected_selection # option
    )

    expect(page).to have_button(update_id)
  end

  def expect_heading(cand, event_name)
    first = cand.candidate_sheet.first_name
    last = cand.candidate_sheet.last_name

    expect(page).to have_selector('h2[id=heading]',
                                  text: I18n.t('views.events.heading',
                                               event_name: event_name, first: first, last: last))
  end
end
