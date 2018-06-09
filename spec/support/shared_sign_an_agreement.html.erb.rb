# frozen_string_literal: true

shared_context 'sign_an_agreement_html_erb' do
  before(:each) do
    AppFactory.add_confirmation_events
    @cand_id = @candidate.id
  end

  scenario 'admin visits form and pushes update' do
    @candidate.sponsor_agreement = false
    @candidate.save

    visit @path

    expect_signed_agreement_form(@cand_id, @dev, @candidate.send(@sign_agreement_getter), @form_action, @field_name, @documant_key, @event_name, @update_id, @is_verify)

    click_button(@update_id)

    candidate = Candidate.find(@cand_id)
    expect_signed_agreement_form(@cand_id, @dev, candidate.send(@sign_agreement_getter), @form_action, @field_name, @documant_key, @event_name, @update_id, @is_verify,
                                 expect_messages: [[:flash_notice, @updated_failed_verification],
                                                   [:error_explanation, ['Your changes were saved!! 1 empty field needs to be filled in on the form to be verfied:', 'By checking you agree to the above. needs to be checked']]])
  end

  scenario 'user(candidate or admin) logs in, selects signing an agreement, has signed agreement previously' do
    @candidate.sponsor_agreement = true
    @candidate.save
    visit @path

    candidate = Candidate.find(@cand_id)
    expect_signed_agreement_form(@cand_id, @dev, candidate.send(@sign_agreement_getter), @form_action, @field_name, @documant_key, @event_name, @update_id, @is_verify)
  end

  scenario 'user(candidate or admin) logs in, signs agreement' do
    @candidate.send(@sign_agreement_setter, false)
    @candidate.save

    visit @path
    check(@field_name)
    click_button(@update_id)

    candidate = Candidate.find(@cand_id)

    if @is_verify

      expect_mass_edit_candidates_event(ConfirmationEvent.find_by(name: @event_name), candidate, @updated_message)

    else
      expect_signed_agreement_form(@cand_id, @dev, candidate.send(@sign_agreement_getter), @form_action, @field_name, @documant_key, @event_name, @update_id, @is_verify, expect_messages: [[:flash_notice, @updated_message]])
    end
  end

  scenario 'candidate unsigns agreement' do
    @candidate.send(@sign_agreement_setter, true)
    @candidate.save

    visit @path

    candidate = Candidate.find(@cand_id)
    expect_signed_agreement_form(@cand_id, @dev, candidate.send(@sign_agreement_getter), @form_action, @field_name, @documant_key, @event_name, @update_id, @is_verify)
    uncheck(@field_name)
    click_button(@update_id)

    candidate = Candidate.find(@cand_id)

    expect_signed_agreement_form(@cand_id, @dev, candidate.send(@sign_agreement_getter), @form_action, @field_name, @documant_key, @event_name, @update_id, @is_verify,
                                 expect_messages: [
                                   [:flash_notice, @updated_failed_verification],
                                   [:error_explanation, ['Your changes were saved!! 1 empty field needs to be filled in on the form to be verfied:', 'By checking you agree to the above. needs to be checked']]
                                 ])
  end

  scenario 'admin un-verifies a verified sponsor agreemtn event' do
    expect(@is_verify == true || @is_verify == false).to eq(true)

    event_name = @event_name
    candidate = Candidate.find(@cand_id)
    candidate.send(@sign_agreement_setter, true)
    today = Time.zone.today
    candidate.get_candidate_event(event_name).completed_date = today
    candidate.get_candidate_event(event_name).verified = true
    candidate.save

    visit @path

    expect_signed_agreement_form(@cand_id, @dev, candidate.send(@sign_agreement_getter), @form_action, @field_name, @documant_key, @event_name, @update_id, @is_verify)

    expect(page).to have_button(I18n.t('views.common.un_verify'), count: 2) if @is_verify
    click_button 'bottom-unverify' if @is_verify

    candidate = Candidate.find(@cand_id)
    if @is_verify
      expect_mass_edit_candidates_event(ConfirmationEvent.find_by(name: event_name), candidate, I18n.t('messages.updated_unverified', cand_name: "#{candidate.candidate_sheet.first_name} #{candidate.candidate_sheet.last_name}"), true)
    else
      expect_signed_agreement_form(@cand_id, @dev, candidate.send(@sign_agreement_getter), @form_action, @field_name, @documant_key, @event_name, @update_id, @is_verify)
    end

    expect(candidate.get_candidate_event(event_name).completed_date).to eq(today)
    expect(candidate.get_candidate_event(event_name).verified).to eq(!@is_verify)
  end

  def expect_signed_agreement_form(cand_id, dev_path, is_agreement_signed, form_action, field_name, documant_key, event_name, update_id, is_verify, values = {})
    expect_messages(values[:expect_messages]) unless values[:expect_messages].nil?

    cand = Candidate.find(cand_id)
    expect_heading(cand, dev_path.empty?, event_name)

    expect(page).to have_selector(form_action)

    if is_agreement_signed
      expect(page).to have_checked_field(field_name)
    else
      expect(page).not_to have_checked_field(field_name)
    end

    expect(page).to have_button(update_id)
    expect(page).to have_button(I18n.t('views.common.un_verify'), count: 2) if is_verify
    expect_download_button(documant_key, cand_id, dev_path)
  end
end
