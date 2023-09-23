# frozen_string_literal: true

# ViewsHelpers
#
module ViewsHelpers
  # LATE_INITIAL_INPUT = I18n.t('email.late_initial_input')
  # COMING_DUE_INITIAL_INPUT = I18n.t('email.coming_due_initial_input')
  # COMPLETE_AWAITING_INITIAL_INPUT = I18n.t('email.completed_awaiting_initial_input')
  # COMPLETE_INITIAL_INPUT = I18n.t('email.completed_initial_input')
  CLOSING_INITIAL_INPUT = I18n.t('email.closing_initial_input')
  # SALUTATION_INITIAL_INPUT = I18n.t('email.salutation_initial_input')
  FROM_EMAIL_INPUT_I18N = 'email.from_initial_input_html'
  SUBJECT = I18n.t('email.subject_initial_input')
  FROM_EMAIL_I18N = 'views.top_bar.contact_admin_mail_text'
  REPLY_TO_EMAIL_I18N = 'views.top_bar.contact_admin_mail_text'

  # Expect Create new Candidate
  #
  # === Parameters:
  #
  # * <tt>:rendered_or_page</tt>
  #
  def expect_create_candidate(rendered_or_page)
    I18n.t('email.salutation_initial_input')
    expect(rendered_or_page).to have_selector(
      'h2',
      text: I18n.t('views.candidates.create_new_candidate')
    )
    expect(rendered_or_page).to have_field(
      I18n.t('activerecord.attributes.candidate_sheet.first_name'), text: ''
    )
    expect(rendered_or_page).to have_field(
      I18n.t('activerecord.attributes.candidate_sheet.middle_name'), text: ''
    )
    expect(rendered_or_page).to have_field(
      I18n.t('activerecord.attributes.candidate_sheet.last_name'), text: ''
    )
    expect(rendered_or_page).to have_field(
      I18n.t('activerecord.attributes.candidate_sheet.candidate_email'), text: ''
    )
    expect(rendered_or_page).to have_field(
      I18n.t('activerecord.attributes.candidate_sheet.parent_email_1'), text: ''
    )
    expect(rendered_or_page).to have_field(
      I18n.t('activerecord.attributes.candidate_sheet.parent_email_2'), text: ''
    )

    expect(rendered_or_page).to have_field(
      I18n.t('activerecord.attributes.candidate_sheet.grade'), text: ''
    )
    expect(rendered_or_page).to have_unchecked_field(
      I18n.t('views.candidates.attending_catholic_high_school'), type: 'radio'
    )
    expect(rendered_or_page).to have_checked_field(
      I18n.t('views.candidates.attending_the_way'), type: 'radio'
    )
  end

  # expect edit or new view.
  #
  # === Parameters:
  #
  # * <tt>:rendered_or_page</tt>
  # * <tt>:candidate</tt>
  # * <tt>:action</tt>
  # * <tt>:submit_button</tt>
  # * <tt>:is_candidate_signed_in</tt>
  # * <tt>:is_new</tt>
  #
  def expect_edit_and_new_view(rendered_or_page, candidate, action, submit_button, is_candidate_signed_in, is_new)
    # rubocop:disable Layout/LineLength
    form_id = is_new ? 'new_candidate' : 'edit_candidate'

    # this matches the partial: candidates/shared/edit_and_new_candidate
    is_candidate_signed_in_and_not_new = (is_candidate_signed_in && !is_new)

    expect(rendered_or_page).to have_selector("form[id=#{form_id}][action=\"#{action}\"]")

    first_name_autofocus = is_candidate_signed_in_and_not_new ? '[autofocus="autofocus"]' : ''
    candidate_autofocus = is_candidate_signed_in_and_not_new ? '' : '[autofocus="autofocus"]'

    expect(rendered_or_page).to have_field(I18n.t('activerecord.attributes.candidate.account_name'), type: 'text', readonly: is_candidate_signed_in_and_not_new)
    expect(rendered_or_page).to have_selector("input[id=candidate_account_name]#{candidate_autofocus}")

    expect(rendered_or_page).to have_field(I18n.t('activerecord.attributes.candidate_sheet.first_name'), with: (candidate ? candidate.candidate_sheet.first_name : ''), type: 'text')
    expect(rendered_or_page).to have_selector("input[id=candidate_candidate_sheet_attributes_first_name]#{first_name_autofocus}")
    expect(rendered_or_page).to have_field(I18n.t('activerecord.attributes.candidate_sheet.middle_name'), with: (candidate ? candidate.candidate_sheet.middle_name : ''), type: 'text')
    expect(rendered_or_page).to have_field(I18n.t('activerecord.attributes.candidate_sheet.last_name'), with: (candidate ? candidate.candidate_sheet.last_name : ''), type: 'text')

    if candidate
      expect(rendered_or_page).to have_field('Grade', with: candidate.candidate_sheet.grade, type: 'number')
    else
      expect(rendered_or_page).to have_field('Grade', type: 'number')
    end

    if candidate&.candidate_sheet&.attending == I18n.t('views.candidates.attending_catholic_high_school')
      expect(rendered_or_page).to have_checked_field(I18n.t('views.candidates.attending_catholic_high_school'), type: 'radio')
      expect(rendered_or_page).to have_unchecked_field(I18n.t('views.candidates.attending_the_way'), type: 'radio')
    else
      expect(rendered_or_page).to have_unchecked_field(I18n.t('views.candidates.attending_catholic_high_school'), type: 'radio')
      expect(rendered_or_page).to have_checked_field(I18n.t('views.candidates.attending_the_way'), type: 'radio')
    end

    expect(rendered_or_page).to have_field('Candidate email', with: (candidate ? candidate.candidate_sheet.candidate_email : ''), type: 'email')
    expect(rendered_or_page).to have_field('Parent email 1', with: (candidate ? candidate.candidate_sheet.parent_email_1 : ''), type: 'email')
    expect(rendered_or_page).to have_field('Parent email 2', with: (candidate ? candidate.candidate_sheet.parent_email_2 : ''), type: 'email')

    expect(rendered_or_page).to have_field('Password', type: 'password')
    expect(rendered_or_page).to have_field('Password confirmation', type: 'password')
    if is_candidate_signed_in_and_not_new
      expect(rendered_or_page).to have_field('Current password', type: 'password')
    else
      expect(rendered_or_page).not_to have_field('Current password', type: 'password')
    end

    expect(rendered_or_page).to have_button(submit_button)
    # rubocop:enable Layout/LineLength
  end

  # create Candidate for testing
  #
  # === Parameters:
  #
  # * <tt>:first_name</tt>
  # * <tt>:middle_name</tt>
  # * <tt>:last_name</tt>
  #
  # === Returns:
  #
  # * <tt>:Candidate</tt>
  #
  def create_candidate(first_name, middle_name, last_name)
    candidate = FactoryBot.create(:candidate, account_name: "#{first_name.downcase}#{last_name.downcase}")
    candidate.candidate_sheet.first_name = first_name
    candidate.candidate_sheet.middle_name = middle_name
    candidate.candidate_sheet.last_name = last_name
    candidate.candidate_sheet.candidate_email = "#{first_name.downcase}@yyy.com"

    candidate.baptismal_certificate.birth_date = '1999-03-05'
    candidate.baptismal_certificate.baptismal_date = '1999-05-05'
    candidate.baptismal_certificate.father_first = 'A'
    candidate.baptismal_certificate.father_middle = 'B'
    candidate.baptismal_certificate.father_last = 'C'
    candidate.baptismal_certificate.mother_first = 'Z'
    candidate.baptismal_certificate.mother_middle = 'Y'
    candidate.baptismal_certificate.mother_maiden = 'X'
    candidate.baptismal_certificate.mother_last = 'W'
    candidate.baptismal_certificate.church_name = 'St Pete'
    candidate.baptismal_certificate.church_address.street_1 = 'The Holy Way'
    candidate.baptismal_certificate.church_address.street_2 = ''
    candidate.baptismal_certificate.church_address.city = 'Very Wet City'
    candidate.baptismal_certificate.church_address.state = 'HA'
    candidate.baptismal_certificate.church_address.zip_code = '12345'

    candidate.sponsor_covenant.sponsor_name = 'The Boss'
    candidate.sponsor_eligibility.sponsor_attends_home_parish = true

    candidate.pick_confirmation_name.saint_name = 'Bolt'

    candidate.save
    candidate
  end

  # checks mass mailing html
  #
  # === Parameters:
  #
  # * <tt>:candidates</tt> list of candidates being mailed
  # * <tt>:rendered_or_page</tt> the html
  #
  def expect_mass_mailing_html(candidates, rendered_or_page)
    # rubocop:disable Layout/LineLength
    expect(rendered_or_page).to have_css "form[action='/monthly_mass_mailing_update']"

    expect(rendered_or_page).to have_css("input[type='submit'][value='#{I18n.t('email.monthly_mail')}']", count: 2)

    expect(rendered_or_page).to have_css("input[id='top-update'][type='submit'][value='#{I18n.t('email.monthly_mail')}']")

    expect(rendered_or_page).to have_field(I18n.t('email.subject_label'), text: I18n.t('email.subject_initial_input'))
    expect(rendered_or_page).to have_field(I18n.t('email.pre_late_input_label'), text: I18n.t('email.late_initial_input'))
    expect(rendered_or_page).to have_field(I18n.t('email.pre_coming_due_input_label'), text: I18n.t('email.coming_due_initial_input'))
    expect(rendered_or_page).to have_field(I18n.t('email.completed_awaiting_input_label'), text: I18n.t('email.completed_awaiting_initial_input'))
    expect(rendered_or_page).to have_field(I18n.t('email.completed_input_label'), text: I18n.t('email.completed_initial_input'))
    expect(rendered_or_page).to have_field(I18n.t('email.closing_input_label'), text: I18n.t('email.closing_initial_input'))
    expect(rendered_or_page).to have_field(I18n.t('email.salutation_input_label'), text: I18n.t('email.salutation_initial_input'))
    expect(rendered_or_page).to have_field(I18n.t('email.from_input_label'), text: 'Vicki Kristoff')

    expect_sorting_candidate_list(common_columns,
                                  candidates,
                                  rendered_or_page)

    expect(rendered_or_page).to have_css("input[id='bottom-update'][type='submit'][value='#{I18n.t('email.monthly_mail')}']")
    # rubocop:enable Layout/LineLength
  end

  # returns lambda
  #
  # === Returns:
  #
  # * <tt>Lambda</tt> candidate_id, rendered_or_page, td_index
  #
  def expect_password_changed
    lambda { |cand_id, rendered_or_page, td_index|
      expect(rendered_or_page).to have_css "td[id=tr#{cand_id}_td#{td_index}]", text: 'true'
    }
  end

  # returns lambda
  #
  # === Returns:
  #
  # * <tt>Lambda</tt> candidate_id, rendered_or_page, td_index
  #
  # returns lambda
  #
  # === Returns:
  #
  # * <tt>Lambda</tt> candidate_id, rendered_or_page, td_index
  #
  def expect_status
    lambda { |cand_id, rendered_or_page, td_index|
      expect(rendered_or_page).to have_css "td[id=tr#{cand_id}_td#{td_index}]", text: I18n.t('label.sidebar.status')
    }
  end

  # expect_note
  #
  # === Returns:
  #
  # * <tt>Lambda</tt> candidate_id, rendered_or_page, td_index
  #
  def expect_note
    lambda { |cand_id, rendered_or_page, td_index|
      expect(rendered_or_page).to have_css "td[id=tr#{cand_id}_td#{td_index}]", text: I18n.t('label.sidebar.candidate_note')
    }
  end

  # returns lambda
  #
  # === Returns:
  #
  # * <tt>Lambda</tt> candidate_id, rendered_or_page, td_index
  #
  def expect_account_confirmed
    lambda { |cand_id, rendered_or_page, td_index|
      candidate = Candidate.find_by(id: cand_id)
      expect(rendered_or_page).to have_css "td[id=tr#{cand_id}_td#{td_index}]", text: candidate.account_confirmed?
    }
  end

  # setup unknown events so can test for them
  #
  def setup_unknown_missing_events
    AppFactory.all_i18n_confirmation_event_keys.each do |event_key|
      AppFactory.add_confirmation_event(event_key) unless event_key == SponsorCovenant.event_key
    end
    AppFactory.add_confirmation_event('unknown event')
  end

  # checks tables have the right size
  #
  # === Parameters:
  #
  # * <tt>:candidate_size</tt>
  # * <tt>:image_size</tt>
  #
  def expect_db(candidate_size, image_size)
    conf_event_size = 9
    # rubocop:disable Layout/LineLength
    expect(ConfirmationEvent.all.size).to eq(conf_event_size), "ConfirmationEvent size #{ConfirmationEvent.all.size} did not meet expected #{conf_event_size}"

    expect(Candidate.all.size).to eq(candidate_size), "Candidate size #{Candidate.all.size} did not meet expected #{candidate_size}"

    expect(BaptismalCertificate.all.size).to eq(candidate_size), "BaptismalCertificate size #{BaptismalCertificate.all.size} did not meet expected #{candidate_size}"
    expect(CandidateSheet.all.size).to eq(candidate_size), "CandidateSheet size #{CandidateSheet.all.size} did not meet expected #{candidate_size}"
    expect(ChristianMinistry.all.size).to eq(candidate_size), "ChristianMinistry size #{ChristianMinistry.all.size} did not meet expected #{candidate_size}"
    expect(PickConfirmationName.all.size).to eq(candidate_size), "PickConfirmationName size #{PickConfirmationName.all.size} did not meet expected #{candidate_size}"
    expect(RetreatVerification.all.size).to eq(candidate_size), "RetreatVerification size #{RetreatVerification.all.size} did not meet expected #{candidate_size}"
    expect(SponsorCovenant.all.size).to eq(candidate_size), "SponsorCovenant size #{SponsorCovenant.all.size} did not meet expected #{candidate_size}"

    # each candidate has 3 + the home parish
    expeced_address_size = candidate_size * 2 + (Visitor.first.nil? ? 0 : 1)
    expect(Address.all.size).to eq(expeced_address_size), "Address size #{Address.all.size} did not meet expected #{expeced_address_size}"
    expect(CandidateEvent.all.size).to eq(candidate_size * conf_event_size), "CandidateEvent size #{CandidateEvent.all.size} did not meet expected #{candidate_size * conf_event_size}"
    expect(ToDo.all.size).to eq(CandidateEvent.all.size), "ToDo size #{ToDo.all.size} did not meet expected #{CandidateEvent.all.size}"

    expect(ScannedImage.all.size).to eq(image_size), "ScannedImages size #{ScannedImage.all.size} did not meet expected #{image_size}"
    # rubocop:enable Layout/LineLength
  end
end
