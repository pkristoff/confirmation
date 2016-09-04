module ViewsHelpers
  def expect_edit_and_new_view(rendered, candidate, action, submit_button, is_candidate_signed_in, is_new)

    form_id = is_new ? 'new_candidate' : 'edit_candidate'

    # this matches the partial: candidates/shared/edit_and_new_candidate
    is_candidate_signed_in_and_not_new = (is_candidate_signed_in and !is_new)

    expect(rendered).to have_selector("form[id=#{form_id}][action=\"#{action}\"]")

    first_name_autofocus = is_candidate_signed_in_and_not_new ? '[autofocus="autofocus"]' : ''
    candidate_autofocus = is_candidate_signed_in_and_not_new ? '' : '[autofocus="autofocus"]'

    expect(rendered).to have_field('Account name', type: 'text', readonly: is_candidate_signed_in_and_not_new)
    expect(rendered).to have_selector("input[id=candidate_account_name]#{candidate_autofocus}")

    expect(rendered).to have_field('First name', with: (candidate ? candidate.candidate_sheet.first_name : ''), type: 'text')
    expect(rendered).to have_selector("input[id=candidate_candidate_sheet_attributes_first_name]#{first_name_autofocus}")
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

    if candidate and candidate.candidate_sheet.attending == I18n.t('views.candidates.attending_catholic_high_school')
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
end