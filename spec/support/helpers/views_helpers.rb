module ViewsHelpers
  def expect_edit_and_new_view(rendered, candidate, action, submit_button, is_candidate_signed_in, is_new)

    form_id = is_new ? 'new_candidate' : 'edit_candidate'

    # this matches the partial: candidates/shared/edit_and_new_candidate
    is_candidate_signed_in_and_not_new = (is_candidate_signed_in and !is_new)

    expect(rendered).to have_selector("form[id=#{form_id}][action=\"#{action}\"]")

    first_name_autofocus = is_candidate_signed_in_and_not_new ? '[autofocus="autofocus"]' : ''
    candidate_autofocus = is_candidate_signed_in_and_not_new ? '' : '[autofocus="autofocus"]'

    expect(rendered).to have_field('Candidate', type: 'text', readonly: is_candidate_signed_in_and_not_new)
    expect(rendered).to have_selector("input[id=candidate_candidate_id]#{candidate_autofocus}")

    expect(rendered).to have_field('First name', with: (candidate ? candidate.first_name : ''), type: 'text')
    expect(rendered).to have_selector("input[id=candidate_first_name]#{first_name_autofocus}")
    expect(rendered).to have_field('Last name', with: (candidate ? candidate.last_name : ''), type: 'text')

    if candidate
      expect(rendered).to have_field('Grade', with: candidate.grade, type: 'number')
    else
      expect(rendered).to have_field('Grade', type: 'number')
    end

    if candidate and candidate.attending == 'Catholic High School'
      expect(rendered).to have_checked_field('Catholic High School', type: 'radio')
      expect(rendered).to have_unchecked_field('The Way', type: 'radio')
    else
      expect(rendered).to have_unchecked_field('Catholic High School', type: 'radio')
      expect(rendered).to have_checked_field('The Way', type: 'radio')
    end

    expect(rendered).to have_field('Candidate email', with: (candidate ? candidate.candidate_email : ''), type: 'email')
    expect(rendered).to have_field('Parent email 1', with: (candidate ? candidate.parent_email_1 : ''), type: 'email')
    expect(rendered).to have_field('Parent email 2', with: (candidate ? candidate.parent_email_2 : ''), type: 'email')

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