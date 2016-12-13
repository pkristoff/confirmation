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

  def expect_sorting_candidate_list(column_headers_in_order, candidates_in_order, rendered_or_page, confirmation_event=nil)

    table_id = "table[id='candidate_list_table']"
    tr_header_id = "tr[id='candidate_list_header']"

    expect(rendered_or_page).to have_css("#{table_id}")
    expect(rendered_or_page).to have_css("#{table_id} #{tr_header_id}")
    expect(rendered_or_page).to have_css "#{table_id} #{tr_header_id} th", count: column_headers_in_order.size

    column_headers_in_order.each_with_index do |info, index|
      i18n_name = info[0]
      sort_enabled = info[1]
      th_header_id = "candidate_list_header_th_#{index+1}"
      basic_th_css = "#{table_id} #{tr_header_id} [id='#{th_header_id}']"
      # expect headers
      if sort_enabled
        expect(rendered_or_page).to have_css basic_th_css, text: i18n_name
      else
        expect(rendered_or_page).to have_css "#{basic_th_css}[class='sorter-false filter-false#{i18n_name === I18n.t('views.nav.edit') ? ' edit_column_header' : ''}']" unless i18n_name === I18n.t('label.candidate_event.select')
        expect(rendered_or_page).to have_css "#{basic_th_css}[class='sorter-false filter-false select_column_header'] input[id='select_all_none_input']" if i18n_name === I18n.t('label.candidate_event.select')
      end
    end
    #expect table cells
    candidates_in_order.each_with_index do |candidate, tr_index|
      tr_id = "tr[id='candidate_list_tr_#{candidate.id}']"
      column_headers_in_order.each_with_index do |info, td_index|
        text = nil
        cell_access_path = info[2]
        cell_expect_function = info[3]
        if cell_access_path.empty?
          cell_expect_function.call(candidate, rendered_or_page, td_index)
        elsif confirmation_event && cell_access_path[0] === :completed_date
          text = candidate.get_candidate_event(confirmation_event.name).method(cell_access_path[0]).call
          expect(rendered_or_page).to have_css "#{table_id} #{tr_id} td", text: text
        else
          text = candidate.method(cell_access_path[0]).call if cell_access_path.size === 1
          text = candidate.method(cell_access_path[0]).call.method(cell_access_path[1]).call if cell_access_path.size === 2
          expect(rendered_or_page).to have_css "#{table_id} #{tr_id} td", text: text
        end
      end
    end
    expect(rendered_or_page).to have_css "#{table_id} tr", count: candidates_in_order.size + 1
  end

  def create_candidate(first_name, last_name)
    candidate = FactoryGirl.create(:candidate, account_name: "#{first_name.downcase}#{last_name.downcase}")
    candidate.candidate_sheet.first_name = first_name
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

    expect(rendered_or_page).to have_css("input[type='submit'][value='#{I18n.t('email.mail')}']", count: 2)

    expect(rendered_or_page).to have_css("input[id='top-update'][type='submit'][value='#{I18n.t('email.mail')}']")

    expect(rendered_or_page).to have_field(I18n.t('email.subject_label'), text: I18n.t('email.subject_initial_text'))
    expect(rendered_or_page).to have_field(I18n.t('email.pre_late_label'), text: I18n.t('email.late_initial_text'))
    expect(rendered_or_page).to have_field(I18n.t('email.coming_due_label'), text: I18n.t('email.coming_due_initial_text'))
    expect(rendered_or_page).to have_field(I18n.t('email.completed_label'), text: I18n.t('email.completed_initial_text'))
    expect(rendered_or_page).to have_field(I18n.t('email.closing_label'), text: I18n.t('email.closing_initial_text'))
    expect(rendered_or_page).to have_field(I18n.t('email.salutation_label'), text: I18n.t('email.salutation_initial_text'))
    expect(rendered_or_page).to have_field(I18n.t('email.from_label'), text: I18n.t('email.from_initial_text'))

    expect_sorting_candidate_list([
                                      [I18n.t('label.candidate_event.select'), false, '', lambda { |candidate, rendered, td_index| expect(rendered).to have_css "input[type=checkbox][id=candidate_candidate_ids_#{candidate.id}]" }],
                                      [I18n.t('label.candidate.account_name'), true, [:account_name], :up],
                                      [I18n.t('label.candidate_sheet.last_name'), true, [:candidate_sheet, :last_name]],
                                      [I18n.t('label.candidate_sheet.first_name'), true, [:candidate_sheet, :first_name]],
                                      [I18n.t('label.candidate_sheet.grade'), true, [:candidate_sheet, :grade]],
                                      [I18n.t('label.candidate_sheet.attending'), true, [:candidate_sheet, :attending]]
                                  ],
                                  candidates,
                                  rendered_or_page)

    expect(rendered_or_page).to have_css("input[id='bottom-update'][type='submit'][value='#{I18n.t('email.mail')}']")
  end
end