# frozen_string_literal: true

shared_context 'sign_an_agreement_html_erb' do
  before(:each) do
    AppFactory.add_confirmation_events
    @cand_id = @candidate.id

    page.driver.header 'Accept-Language', locale
    I18n.locale = locale

    cand_name = 'Sophia Agusta'
    if @is_verify
      @updated_message = I18n.t('messages.updated_verified', cand_name: cand_name)
      @updated_failed_verification = I18n.t('messages.updated_not_verified', cand_name: cand_name)
    else
      @updated_message = I18n.t('messages.updated', cand_name: cand_name)
      @updated_failed_verification = I18n.t('messages.updated', cand_name: cand_name)
    end
  end

  scenario 'admin visits form and pushes update' do
    # rubocop:disable Layout/LineLength
    @candidate.signed_agreement = false
    @candidate.save

    visit @path

    expect_signed_agreement_form(@cand_id, @dev, @candidate.send(@sign_agreement_getter), @form_action, @field_name, @document_key, @event_key, @update_id, @is_verify)

    click_button(@update_id)

    candidate = Candidate.find(@cand_id)
    expect_signed_agreement_form(@cand_id, @dev, candidate.send(@sign_agreement_getter), @form_action, @field_name, @document_key, @event_key, @update_id, @is_verify,
                                 expected_messages: [[:flash_notice, @updated_failed_verification],
                                                     [:error_explanation, [I18n.t('messages.error.missing_attribute', err_count: 1),
                                                                           I18n.t('messages.signed_agreement_val', field_name: I18n.t('label.sign_agreement.signed_agreement'))]]])
    # rubocop:enable Layout/LineLength
  end

  scenario 'user(candidate or admin) logs in, selects signing an agreement, has signed agreement previously' do
    @candidate.signed_agreement = true
    @candidate.save
    visit @path

    candidate = Candidate.find(@cand_id)
    expect_signed_agreement_form(@cand_id, @dev, candidate.send(@sign_agreement_getter), @form_action, @field_name,
                                 @document_key, @event_key, @update_id, @is_verify)
  end

  scenario 'user(candidate or admin) logs in, signs agreement' do
    @candidate.send(@sign_agreement_setter, false)
    @candidate.save

    visit @path
    check(@field_name)
    click_button(@update_id)

    candidate = Candidate.find(@cand_id)

    if @is_verify

      expect_mass_edit_candidates_event(ConfirmationEvent.find_by(event_key: @event_key),
                                        candidate.id, @updated_message)

    else
      expect_signed_agreement_form(@cand_id, @dev, candidate.send(@sign_agreement_getter), @form_action, @field_name,
                                   @document_key, @event_key, @update_id, @is_verify,
                                   expected_messages: [[:flash_notice, @updated_message]])
    end
  end

  scenario 'candidate unsigns agreement' do
    @candidate.send(@sign_agreement_setter, true)
    @candidate.save

    visit @path

    candidate = Candidate.find(@cand_id)
    expect_signed_agreement_form(@cand_id, @dev, candidate.send(@sign_agreement_getter), @form_action, @field_name,
                                 @document_key, @event_key, @update_id, @is_verify)
    uncheck(@field_name)
    click_button(@update_id)

    candidate = Candidate.find(@cand_id)

    expected_msg = I18n.t('messages.signed_agreement_val', field_name: I18n.t('label.sign_agreement.signed_agreement'))
    expect_signed_agreement_form(@cand_id, @dev, candidate.send(@sign_agreement_getter), @form_action, @field_name,
                                 @document_key, @event_key, @update_id, @is_verify,
                                 expected_messages: [
                                   [:flash_notice, @updated_failed_verification],
                                   [:error_explanation, [I18n.t('messages.error.missing_attribute', err_count: 1),
                                                         expected_msg]]
                                 ])
  end

  scenario 'admin un-verifies a verified sponsor agreement event' do
    # rubocop:disable Layout/LineLength
    expect(@is_verify == true || @is_verify == false).to eq(true)

    event_key = @event_key
    candidate = Candidate.find(@cand_id)
    candidate.send(@sign_agreement_setter, true)
    today = Time.zone.today
    candidate.get_candidate_event(event_key).completed_date = today
    candidate.get_candidate_event(event_key).verified = true
    candidate.save

    visit @path

    expect_signed_agreement_form(@cand_id, @dev, candidate.send(@sign_agreement_getter), @form_action, @field_name, @document_key, event_key, @update_id, @is_verify)

    expect(page).to have_button(I18n.t('views.common.un_verify'), count: 2) if @is_verify
    click_button 'bottom-unverify' if @is_verify

    candidate = Candidate.find(@cand_id)
    if @is_verify
      expect_mass_edit_candidates_event(ConfirmationEvent.find_by(event_key: event_key), candidate.id, I18n.t('messages.updated_unverified', cand_name: "#{candidate.candidate_sheet.first_name} #{candidate.candidate_sheet.last_name}"), { is_unverified: true })
    else
      expect_signed_agreement_form(@cand_id, @dev, candidate.send(@sign_agreement_getter), @form_action, @field_name, @document_key, @event_key, @update_id, @is_verify)
    end

    expect(candidate.get_candidate_event(event_key).completed_date).to eq(today)
    expect(candidate.get_candidate_event(event_key).verified).to eq(!@is_verify)
    # rubocop:enable Layout/LineLength
  end

  private

  def expect_signed_agreement_form(cand_id, dev_path, is_agreement_signed, form_action, field_name,
                                   documant_key, event_key, update_id, is_verify, values = {})
    expect_messages(values[:expected_messages]) unless values[:expected_messages].nil?

    cand = Candidate.find(cand_id)
    expect_heading(cand, dev_path.empty?, event_key)

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
