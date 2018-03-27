# frozen_string_literal: true

module ViewsHelpers
  LATE_INITIAL_TEXT = I18n.t('email.late_initial_text')
  COMING_DUE_INITIAL_TEXT = I18n.t('email.coming_due_initial_text')
  COMPLETE_AWAITING_INITIAL_TEXT = I18n.t('email.completed_awaiting_initial_text')
  COMPLETE_INITIAL_TEXT = I18n.t('email.completed_initial_text')
  CLOSING_INITIAL_TEXT = I18n.t('email.closing_initial_text')
  SALUTATION_INITIAL_TEXT = I18n.t('email.salutation_initial_text')
  FROM_EMAIL_TEXT = I18n.t('email.from_initial_text_html')
  SUBJECT = I18n.t('email.subject_initial_text')
  FROM_EMAIL = I18n.t('views.top_bar.contact_admin_mail_text')
  REPLY_TO_EMAIL = I18n.t('views.top_bar.contact_admin_mail_text')

  def expect_edit_and_new_view(rendered, candidate, action, submit_button, is_candidate_signed_in, is_new)
    form_id = is_new ? 'new_candidate' : 'edit_candidate'

    # this matches the partial: candidates/shared/edit_and_new_candidate
    is_candidate_signed_in_and_not_new = (is_candidate_signed_in && !is_new)

    expect(rendered).to have_selector("form[id=#{form_id}][action=\"#{action}\"]")

    first_name_autofocus = is_candidate_signed_in_and_not_new ? '[autofocus="autofocus"]' : ''
    candidate_autofocus = is_candidate_signed_in_and_not_new ? '' : '[autofocus="autofocus"]'

    expect(rendered).to have_field('Account name', type: 'text', readonly: is_candidate_signed_in_and_not_new)
    expect(rendered).to have_selector("input[id=candidate_account_name]#{candidate_autofocus}")

    expect(rendered).to have_field('First name', with: (candidate ? candidate.candidate_sheet.first_name : ''), type: 'text')
    expect(rendered).to have_selector("input[id=candidate_candidate_sheet_attributes_first_name]#{first_name_autofocus}")
    expect(rendered).to have_field('Middle name', with: (candidate ? candidate.candidate_sheet.middle_name : ''), type: 'text')
    expect(rendered).to have_field('Last name', with: (candidate ? candidate.candidate_sheet.last_name : ''), type: 'text')

    expect(rendered).to have_field('Street 1', with: (candidate ? candidate.candidate_sheet.address.street_1 : ''), type: 'text')
    expect(rendered).to have_field('Street 2', with: (candidate ? candidate.candidate_sheet.address.street_2 : ''), type: 'text')
    expect(rendered).to have_field('City', with: (candidate ? candidate.candidate_sheet.address.city : 'Apex'), type: 'text')
    expect(rendered).to have_field('State', with: (candidate ? candidate.candidate_sheet.address.state : 'NC'), type: 'text')
    expect(rendered).to have_field('Zip code', with: (candidate ? candidate.candidate_sheet.address.zip_code : '27502'), type: 'text')

    if candidate
      expect(rendered).to have_field('Grade', with: candidate.candidate_sheet.grade, type: 'number')
    else
      expect(rendered).to have_field('Grade', type: 'number')
    end

    if candidate&.candidate_sheet&.attending == I18n.t('views.candidates.attending_catholic_high_school')
      expect(rendered).to have_checked_field(I18n.t('views.candidates.attending_catholic_high_school'), type: 'radio')
      expect(rendered).to have_unchecked_field(I18n.t('views.candidates.attending_the_way'), type: 'radio')
    else
      expect(rendered).to have_unchecked_field(I18n.t('views.candidates.attending_catholic_high_school'), type: 'radio')
      expect(rendered).to have_checked_field(I18n.t('views.candidates.attending_the_way'), type: 'radio')
    end

    expect(rendered).to have_field('Candidate email', with: (candidate ? candidate.candidate_sheet.candidate_email : ''), type: 'email')
    expect(rendered).to have_field('Parent email 1', with: (candidate ? candidate.candidate_sheet.parent_email_1 : ''), type: 'email')
    expect(rendered).to have_field('Parent email 2', with: (candidate ? candidate.candidate_sheet.parent_email_2 : ''), type: 'email')

    expect(rendered).to have_field('Password', type: 'password')
    expect(rendered).to have_field('Password confirmation', type: 'password')
    if is_candidate_signed_in_and_not_new
      expect(rendered).to have_field('Current password', type: 'password')
    else
      expect(rendered).not_to have_field('Current password', type: 'password')
    end

    expect(rendered).to have_button(submit_button)
  end

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
    candidate.sponsor_covenant.sponsor_attends_stmm = true

    candidate.pick_confirmation_name.saint_name = 'Bolt'

    candidate.save
    candidate
  end

  def expect_mass_mailing_html(candidates, rendered_or_page)
    expect(rendered_or_page).to have_css "form[action='/monthly_mass_mailing_update']"

    expect(rendered_or_page).to have_css("input[type='submit'][value='#{I18n.t('email.monthly_mail')}']", count: 2)

    expect(rendered_or_page).to have_css("input[id='top-update'][type='submit'][value='#{I18n.t('email.monthly_mail')}']")

    expect(rendered_or_page).to have_field(I18n.t('email.subject_label'), text: I18n.t('email.subject_initial_text'))
    expect(rendered_or_page).to have_field(I18n.t('email.pre_late_text_label'), text: I18n.t('email.late_initial_text'))
    expect(rendered_or_page).to have_field(I18n.t('email.pre_coming_due_text_label'), text: I18n.t('email.coming_due_initial_text'))
    # had to break this into two parts because it could not be found together.  I think it is a bug with RSpec.
    expect(rendered_or_page).to have_field(I18n.t('email.completed_awaiting_text_label'))
    expect(rendered_or_page).to have_content(I18n.t('email.completed_awaiting_initial_text'))
    expect(rendered_or_page).to have_field(I18n.t('email.completed_text_label'))
    expect(rendered_or_page).to have_content(I18n.t('email.completed_initial_text'))
    expect(rendered_or_page).to have_field(I18n.t('email.closing_text_label'), text: I18n.t('email.closing_initial_text'))
    expect(rendered_or_page).to have_field(I18n.t('email.salutation_text_label'), text: I18n.t('email.salutation_initial_text'))
    expect(rendered_or_page).to have_field(I18n.t('email.from_text_label'), text: 'Vicki Kristoff')

    expect_sorting_candidate_list(common_columns,
                                  candidates,
                                  rendered_or_page)

    expect(rendered_or_page).to have_css("input[id='bottom-update'][type='submit'][value='#{I18n.t('email.monthly_mail')}']")
  end

  def expect_password_changed
    ->(candidate, rendered, td_index) { expect(rendered).to have_css "td[id=tr#{candidate.id}_td#{td_index}]", text: 'true' }
  end

  def expect_account_confirmed
    ->(candidate, rendered, td_index) { expect(rendered).to have_css "td[id=tr#{candidate.id}_td#{td_index}]", text: candidate.account_confirmed? }
  end

  def setup_unknown_missing_events
    AppFactory.all_i18n_confirmation_event_names.each do |i18n_name|
      i18n_confirmation_name = I18n.t(i18n_name)
      AppFactory.add_confirmation_event(i18n_confirmation_name) unless i18n_name == 'events.sponsor_covenant'
    end
    AppFactory.add_confirmation_event('unknown event')
  end

  def expect_db(candidate_size, conf_event_size, image_size)
    expect(ConfirmationEvent.all.size).to eq(conf_event_size), "ConfirmationEvent size #{ConfirmationEvent.all.size} did not meet expected #{conf_event_size}"

    expect(Candidate.all.size).to eq(candidate_size), "Candidate size #{Candidate.all.size} did not meet expected #{candidate_size}"

    expect(BaptismalCertificate.all.size).to eq(candidate_size), "BaptismalCertificate size #{BaptismalCertificate.all.size} did not meet expected #{candidate_size}"
    expect(CandidateSheet.all.size).to eq(candidate_size), "CandidateSheet size #{CandidateSheet.all.size} did not meet expected #{candidate_size}"
    expect(ChristianMinistry.all.size).to eq(candidate_size), "ChristianMinistry size #{ChristianMinistry.all.size} did not meet expected #{candidate_size}"
    expect(PickConfirmationName.all.size).to eq(candidate_size), "PickConfirmationName size #{PickConfirmationName.all.size} did not meet expected #{candidate_size}"
    expect(RetreatVerification.all.size).to eq(candidate_size), "RetreatVerification size #{RetreatVerification.all.size} did not meet expected #{candidate_size}"
    expect(SponsorCovenant.all.size).to eq(candidate_size), "SponsorCovenant size #{SponsorCovenant.all.size} did not meet expected #{candidate_size}"

    expect(Address.all.size).to eq(candidate_size * 2), "Address size #{Address.all.size} did not meet expected #{candidate_size * 2}"
    expect(CandidateEvent.all.size).to eq(candidate_size * conf_event_size), "CandidateEvent size #{CandidateEvent.all.size} did not meet expected #{candidate_size * conf_event_size}"
    expect(ToDo.all.size).to eq(CandidateEvent.all.size), "ToDo size #{ToDo.all.size} did not meet expected #{CandidateEvent.all.size}"

    expect(ScannedImage.all.size).to eq(image_size), "ScannedImages size #{ScannedImage.all.size} did not meet expected #{image_size}"
  end
end
