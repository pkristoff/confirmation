# frozen_string_literal: true

require_relative 'helpers/sorting_cand_list_helper.rb'

RSpec.configure do |c|
  c.include SortingCandListHelpers
end

SAINT_NAME = 'George Sponsor'

shared_context 'pick_confirmation_name_html_erb' do
  include ViewsHelpers
  before(:each) do
    AppFactory.add_confirmation_events
    @candidate = Candidate.find_by(account_name: @candidate.account_name)
    @cand_id = @candidate.id

    page.driver.header 'Accept-Language', locale
    I18n.locale = locale

    cand_name = 'Sophia Agusta'
    if @is_verify
      @updated_message = I18n.t('messages.updated_verified', cand_name: cand_name)
      @updated_failed_verification = I18n.t('messages.updated_not_verified', cand_name: cand_name)
      @admin_verified = true
    else
      @updated_message = I18n.t('messages.updated', cand_name: cand_name)
      @updated_failed_verification = I18n.t('messages.updated', cand_name: cand_name)
      @admin_verified = false
    end
    @dev_path = @is_dev ? 'dev/' : ''
    @today = Time.zone.today
  end

  scenario 'admin logs in and selects a candidate, nothing else showing' do
    update_pick_confirmation_name(false)
    visit @path
    expect_pick_confirmation_name_form(@cand_id, @path_str, @dev_path, @update_id, @is_verify, expect_messages: [])
  end

  scenario 'admin logs in and selects a candidate, fills in template' do
    update_pick_confirmation_name(false)

    expect_db(1, 8, 0)

    visit @path
    fill_in_form
    click_button @update_id

    if @admin_verified

      expect_mass_edit_candidates_event(ConfirmationEvent.find_by(event_key: PickConfirmationName.event_key), @candidate.id, @updated_message)

    else
      candidate = Candidate.find(@cand_id)
      expect_pick_confirmation_name_form(@cand_id, @path_str, @dev_path, @update_id, @is_verify, saint_name: '', expect_messages: [[:flash_notice, @updated_message]])
      expect(candidate.pick_confirmation_name.saint_name).to eq(SAINT_NAME)

      expect(candidate.get_candidate_event(PickConfirmationName.event_key).completed_date).to eq(@today)
      expect(candidate.get_candidate_event(PickConfirmationName.event_key).verified).to eq(false)

      expect_db(1, 8, 0) # make sure DB does not increase in size.
    end
  end

  scenario 'admin logs in and selects a candidate, adds picture, updates, adds rest of valid data, updates - everything is saved' do
    update_pick_confirmation_name(false)
    visit @path

    click_button @update_id

    candidate = Candidate.find(@candidate.id)

    expect_pick_confirmation_name_form(@cand_id, @path_str, @dev_path, @update_id, @is_verify, saint_name: '', expect_messages: [[:flash_notice, @updated_failed_verification],
                                                                                                                                 [:error_explanation, [I18n.t('messages.error.missing_attribute', err_count: 1),
                                                                                                                                                       "Saint name #{I18n.t('errors.messages.blank')}"]]])
    expect(candidate.pick_confirmation_name.saint_name).to eq('')

    fill_in_form # no picture
    click_button @update_id

    candidate = Candidate.find(@candidate.id)

    if @admin_verified

      expect_mass_edit_candidates_event(ConfirmationEvent.find_by(event_key: PickConfirmationName.event_key), @candidate.id, @updated_message)

    else

      expect(candidate.pick_confirmation_name.saint_name).to eq(SAINT_NAME)

      expect_pick_confirmation_name_form(@cand_id, @path_str, @dev_path, @update_id, @is_verify, saint_name: SAINT_NAME, expect_messages: [[:flash_notice, @updated_failed_verification]])

    end
  end

  scenario 'admin logs in and selects a candidate, fills in template, except saint_name' do
    update_pick_confirmation_name(false)

    visit @path
    fill_in_form
    fill_in(I18n.t('label.confirmation_name.saint_name'), with: nil)
    click_button @update_id

    candidate = Candidate.find(@candidate.id)
    expect_pick_confirmation_name_form(@cand_id, @path_str, @dev_path, @update_id, @is_verify,
                                       saint_name: '',
                                       expect_messages: [[:flash_notice, @updated_failed_verification],
                                                         [:error_explanation, [I18n.t('messages.error.missing_attribute', err_count: 1), "Saint name #{I18n.t('errors.messages.blank')}"]]])

    expect(candidate.get_candidate_event(PickConfirmationName.event_key).completed_date).to eq(nil)
    expect(candidate.get_candidate_event(PickConfirmationName.event_key).verified).to eq(false)
  end

  scenario 'admin un-verifies a verified pick confirmation name event' do
    expect(@is_verify == true || @is_verify == false).to eq(true)

    event_key = PickConfirmationName.event_key
    candidate = Candidate.find(@cand_id)
    candidate.get_candidate_event(event_key).completed_date = @today
    candidate.get_candidate_event(event_key).verified = true
    candidate.save
    update_pick_confirmation_name(true)

    visit @path

    expect_pick_confirmation_name_form(@cand_id, @path_str, @dev_path, @update_id, @is_verify)

    expect(page).to have_button(I18n.t('views.common.un_verify'), count: 2) if @is_verify
    click_button 'bottom-unverify' if @is_verify

    candidate = Candidate.find(@candidate.id)
    if @is_verify
      expect_mass_edit_candidates_event(ConfirmationEvent.find_by(event_key: event_key), candidate.id, I18n.t('messages.updated_unverified', cand_name: "#{candidate.candidate_sheet.first_name} #{candidate.candidate_sheet.last_name}"), true)
    else
      expect_pick_confirmation_name_form(@cand_id, @path_str, @dev_path, @update_id, @is_verify)
    end

    expect(candidate.get_candidate_event(event_key).completed_date).to eq(@today)
    expect(candidate.get_candidate_event(event_key).verified).to eq(!@is_verify)
  end

  def fill_in_form
    fill_in(I18n.t('label.confirmation_name.saint_name'), with: SAINT_NAME)
  end

  def update_pick_confirmation_name(with_values)
    @candidate.pick_confirmation_name.saint_name = SAINT_NAME if with_values
    @candidate.save if with_values
  end
end
