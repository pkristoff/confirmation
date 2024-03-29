# frozen_string_literal: true

require_relative 'helpers/sorting_cand_list_helper'

WHAT_SERVICE = '9am mass'
WHERE_SERVICE = 'Over there'
WHEN_SERVICE = 'Yesterday'
HELPED_ME = 'look better'

RSpec.configure do |c|
  c.include SortingCandListHelpers
end

# rubocop:disable RSpec/ContextWording
shared_context 'christian_ministry_html_erb' do
  # rubocop:enable RSpec/ContextWording
  include ViewsHelpers
  before do
    FactoryBot.create(:visitor)
    @today = Time.zone.today
    @cand_id = @candidate.id

    page.driver.header 'Accept-Language', locale
    I18n.locale = locale

    cand_name = 'Sophia Augusta'
    if @is_verify
      @updated_message = I18n.t('messages.updated_verified', cand_name: cand_name)
      @updated_failed_verification = I18n.t('messages.updated_not_verified', cand_name: cand_name)
    else
      @updated_message = I18n.t('messages.updated', cand_name: cand_name)
      @updated_failed_verification = I18n.t('messages.updated', cand_name: cand_name)
    end

    @admin_verified = @is_verify
    @dev_path = @is_dev ? 'dev/' : ''
    AppFactory.add_confirmation_events
  end

  it 'admin logs in and selects a candidate, nothing else showing' do
    update_christian_ministry(false)
    visit @path

    expect_christian_ministry_form(@cand_id, @path_str, @dev_path, @update_id, @is_verify,
                                   what_service: '', where_service: '',
                                   when_service: '', helped_me: '')
  end

  it 'admin logs in and selects a candidate, fills in template and no picture' do
    update_christian_ministry(false)

    expect_db(1, 0)
    visit @path

    fill_in_form
    click_button @update_id

    candidate = Candidate.find(@cand_id)

    if @admin_verified

      expect_mass_edit_candidates_event(ConfirmationEvent.find_by(event_key: ChristianMinistry.event_key),
                                        candidate.id, @updated_message)

    else
      expect_christian_ministry_form(@cand_id, @path_str, @dev_path, @update_id, @is_verify,
                                     what_service: WHAT_SERVICE, where_service: WHERE_SERVICE,
                                     when_service: WHEN_SERVICE, helped_me: HELPED_ME,
                                     expected_messages: [[:flash_notice, @updated_message]])
    end

    expect(candidate.get_candidate_event(ChristianMinistry.event_key).completed_date).to eq(@today)
    expect(candidate.get_candidate_event(ChristianMinistry.event_key).verified).to be(true)

    visit @path

    expect_christian_ministry_form(@cand_id, @path_str, @dev_path, @update_id, @is_verify,
                                   what_service: '', where_service: WHERE_SERVICE,
                                   when_service: WHEN_SERVICE, helped_me: HELPED_ME)

    expect_db(1, 0) # make sure DB does not increase in size.
  end

  it 'admin logs in and selects a candidate, fills in template and picture' do
    update_christian_ministry(false)

    expect_db(1, 0)

    visit @path
    fill_in_form
    click_button @update_id

    candidate = Candidate.find(@cand_id)
    if @admin_verified

      expect_mass_edit_candidates_event(ConfirmationEvent.find_by(event_key: ChristianMinistry.event_key),
                                        candidate.id, @updated_message)

    else

      expect_christian_ministry_form(@cand_id, @path_str, @dev_path, @update_id, @is_verify,
                                     what_service: WHAT_SERVICE, where_service: WHERE_SERVICE,
                                     when_service: WHEN_SERVICE, helped_me: HELPED_ME,
                                     expected_messages: [[:flash_notice, @updated_message]])
    end

    expect(candidate.get_candidate_event(ChristianMinistry.event_key).completed_date).to eq(@today)
    expect(candidate.get_candidate_event(ChristianMinistry.event_key).verified).to be(true)

    visit @path
    expect_christian_ministry_form(@cand_id, @path_str, @dev_path, @update_id, @is_verify,
                                   what_service: '', where_service: WHERE_SERVICE,
                                   when_service: WHEN_SERVICE, helped_me: HELPED_ME)

    expect_db(1, 0) # make sure DB does not increase in size.
  end

  it 'admin logs in and selects a candidate, adds picture, updates, updates - everything is saved' do
    candidate = Candidate.find(@cand_id)
    candidate.save
    update_christian_ministry(false)

    expect_db(1, 0)
    visit @path

    click_button @update_id

    expected_msg = I18n.t('messages.error.missing_attributes', err_count: 4)
    expect_christian_ministry_form(@cand_id, @path_str, @dev_path, @update_id, @is_verify,
                                   what_service: '', where_service: '',
                                   when_service: '', helped_me: '',
                                   expected_messages: [[:flash_notice, @updated_failed_verification],
                                                       [:error_explanation, [expected_msg,
                                                                             "What service #{I18n.t('errors.messages.blank')}",
                                                                             "Where service #{I18n.t('errors.messages.blank')}",
                                                                             "When service #{I18n.t('errors.messages.blank')}",
                                                                             "Helped me #{I18n.t('errors.messages.blank')}"]]])

    candidate = Candidate.find(@cand_id)
    expect(candidate.get_candidate_event(ChristianMinistry.event_key).completed_date).to be_nil
    expect(candidate.get_candidate_event(ChristianMinistry.event_key).verified).to be(false)

    visit @path
    expect_christian_ministry_form(@cand_id, @path_str, @dev_path, @update_id, @is_verify,
                                   what_service: '', where_service: '',
                                   when_service: '', helped_me: '')

    expect_db(1, 0) # make sure DB does not increase in size.
  end

  it 'admin logs in and selects a candidate, fills in template, except saint_name' do
    update_christian_ministry(false)

    expect_db(1, 0)

    visit @path
    fill_in_form
    fill_in(I18n.t('activerecord.attributes.christian_ministry.what_service'), with: nil)
    click_button @update_id

    expected_msg = I18n.t('messages.error.missing_attribute', err_count: 1)
    expect_christian_ministry_form(@cand_id, @path_str, @dev_path, @update_id, @is_verify,
                                   what_service: '', where_service: WHERE_SERVICE,
                                   when_service: WHEN_SERVICE, helped_me: HELPED_ME,
                                   expected_messages: [[:flash_notice, @updated_failed_verification],
                                                       [:error_explanation, [expected_msg,
                                                                             "What service #{I18n.t('errors.messages.blank')}"]]])

    expect_db(1, 0) # make sure DB does not increase in size.
  end

  it 'admin un-verifies a verified christian ministry event' do
    expect(@is_verify == true || @is_verify == false).to be(true)

    event_key = ChristianMinistry.event_key
    candidate = Candidate.find(@cand_id)
    candidate.christian_ministry.what_service = 'lll'
    candidate.christian_ministry.when_service = 'kkk'
    candidate.christian_ministry.where_service = 'ppp'
    candidate.christian_ministry.helped_me = 'ooo'

    candidate.get_candidate_event(event_key).completed_date = @today
    candidate.get_candidate_event(event_key).verified = true
    candidate.save
    update_christian_ministry(true)

    visit @path

    expect_christian_ministry_form(@cand_id, @path_str, @dev_path, @update_id, @is_verify)

    expect(page).to have_button(I18n.t('views.common.un_verify'), count: 2) if @is_verify
    click_button 'bottom-unverify' if @is_verify

    candidate = Candidate.find(@candidate.id)
    if @is_verify
      # rubocop:disable Layout/LineLength
      expect_mass_edit_candidates_event(ConfirmationEvent.find_by(event_key: event_key), candidate.id, I18n.t('messages.updated_unverified', cand_name: "#{candidate.candidate_sheet.first_name} #{candidate.candidate_sheet.last_name}"), is_unverified: true)
      # rubocop:enable Layout/LineLength
    else
      expect_christian_ministry_form(@cand_id, @path_str, @dev_path, @update_id, @is_verify)
    end

    expect(candidate.get_candidate_event(event_key).completed_date).to eq(@today)
    expect(candidate.get_candidate_event(event_key).verified).to eq(!@is_verify)
  end

  private

  def fill_in_form
    fill_in(I18n.t('activerecord.attributes.christian_ministry.what_service'), with: WHAT_SERVICE)
    fill_in(I18n.t('activerecord.attributes.christian_ministry.where_service'), with: WHERE_SERVICE)
    fill_in(I18n.t('activerecord.attributes.christian_ministry.when_service'), with: WHEN_SERVICE)
    fill_in(I18n.t('activerecord.attributes.christian_ministry.helped_me'), with: HELPED_ME)
  end

  def img_src_selector
    "img[src=\"/#{@dev_path}event_with_picture_image/#{@cand_id}/christian_ministry\"]"
  end

  def update_christian_ministry(with_values)
    @candidate.christian_ministry.what_service = WHAT_SERVICE if with_values
    @candidate.save if with_values
  end
end
