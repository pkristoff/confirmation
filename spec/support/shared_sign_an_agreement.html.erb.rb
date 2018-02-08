shared_context 'sign_an_agreement_html_erb' do

  before(:each) do
    AppFactory.add_confirmation_events
    @cand_id = @candidate.id
  end

  scenario 'admin visits form and pushes update' do
    @candidate.sponsor_agreement = false
    @candidate.save

    visit @path

    expect_signed_agreement_form(@cand_id, @dev, @candidate.send(@sign_agreement_getter), @form_action, @field_name, @documant_key, @event_name, @update_id)

    click_button(@update_id)

    candidate = Candidate.find(@cand_id)
    expect_signed_agreement_form(@cand_id, @dev, candidate.send(@sign_agreement_getter), @form_action, @field_name, @documant_key, @event_name, @update_id,
                                    expect_messages: [[:flash_notice, @updated_failed_verification],
                                                    [:error_explanation, "Your changes were saved!! 1 empty field needs to be filled in on the form to be verfied: By checking you agree to the above. needs to be checked"]
                                  ])

  end

  scenario 'user(candidate or admin) logs in, selects signing an agreement, has signed agreement previously' do
    @candidate.sponsor_agreement = true
    @candidate.save
    visit @path

    candidate = Candidate.find(@cand_id)
    expect_signed_agreement_form(@cand_id, @dev, candidate.send(@sign_agreement_getter), @form_action, @field_name, @documant_key, @event_name, @update_id)
  end

  scenario 'user(candidate or admin) logs in, signs agreement' do

    @candidate.send(@sign_agreement_setter, false)
    @candidate.save
    confirmation_event = ConfirmationEvent.find_by_name(@event_name)

    visit @path
    check(@field_name)
    click_button(@update_id)

    candidate = Candidate.find(@cand_id)

    if @is_verify

      expect_mass_edit_candidates_event(ConfirmationEvent.find_by_name(@event_name), candidate, @updated_message)

    else
      expect_signed_agreement_form(@cand_id, @dev, candidate.send(@sign_agreement_getter), @form_action, @field_name, @documant_key, @event_name, @update_id,
                                      expect_messages: [[:flash_notice, @updated_message]])
    end
  end

  scenario 'candidate unsigns agreement' do

    @candidate.send(@sign_agreement_setter, true)
    @candidate.save
    confirmation_event = ConfirmationEvent.find_by_name(@event_name)

    visit @path

    candidate = Candidate.find(@cand_id)
    expect_signed_agreement_form(@cand_id, @dev, candidate.send(@sign_agreement_getter), @form_action, @field_name, @documant_key, @event_name, @update_id)
    uncheck(@field_name)
    click_button(@update_id)

    candidate = Candidate.find(@cand_id)
    expect_signed_agreement_form(@cand_id, @dev, candidate.send(@sign_agreement_getter), @form_action, @field_name, @documant_key, @event_name, @update_id,
                                    expect_messages: [[:flash_notice, @updated_failed_verification],
                                                    [:error_explanation, "Your changes were saved!! 1 empty field needs to be filled in on the form to be verfied: By checking you agree to the above. needs to be checked"]
                                  ])

  end

  def expect_signed_agreement_form(cand_id, dev_path, is_agreement_signed, form_action, field_name, documant_key, event_name, update_id, values = {})

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
    expect_download_button(documant_key, cand_id, dev_path)
  end

end
