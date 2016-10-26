describe 'admins/monthly_mass_mailing.html.erb' do

  before(:each) do

    AppFactory.add_confirmation_events
    @candidate_1 = create_candidate('Vicki', 'Kristoff')
    @candidate_2 = create_candidate('Paul', 'Kristoff')
  end


  it 'display the list of candidates' do

    table_id = "table[id='candidate_list_table']"
    tr_header_id = "tr[id='candidate_list_header']"
    column_headers_in_order = [
        t('label.candidate_event.select'),
        t('label.candidate.account_name'),
        t('label.candidate_sheet.last_name'),
        t('label.candidate_sheet.first_name'),
        t('label.candidate_sheet.grade'),
        t('label.candidate_sheet.attending')
    ]

    @candidates = [@candidate_1, @candidate_2]

    render

    expect(rendered).to have_css "form[action='/monthly_mass_mailing_update']"

    expect(rendered).to have_css("input[id='top-update'][type='submit'][value='#{t('views.common.update')}']")

    expect(rendered).to have_field(t('email.pre_late_label'), text: t('email.late_initial_text'))
    expect(rendered).to have_field(t('email.coming_due_label'), text: t('email.coming_due_initial_text'))
    expect(rendered).to have_field(t('email.completed_label'), text: t('email.completed_initial_text'))

    expect(rendered).to have_css("#{table_id}")
    expect(rendered).to have_css("#{table_id} #{tr_header_id}")
    expect(rendered).to have_css "#{table_id} #{tr_header_id} th", count: column_headers_in_order.size
    column_headers_in_order.each_with_index do |header, index|
      expect(rendered).to have_css "#{table_id} #{tr_header_id} [id='candidate_list_header_th_#{index+1}']", text: header
    end

    @candidates.each_with_index do |candidate, index|
      tr_id = "tr[id='candidate_list_tr_#{candidate.id}']"
      expect(rendered).to have_css "input[type=checkbox][id=candidate_candidate_ids_#{candidate.id}]"
      expect(rendered).to have_css "#{table_id} #{tr_id} td", text: candidate.account_name
      expect(rendered).to have_css "#{table_id} #{tr_id} td", text: candidate.candidate_sheet.last_name
      expect(rendered).to have_css "#{table_id} #{tr_id} td", text: candidate.candidate_sheet.first_name
      expect(rendered).to have_css "#{table_id} #{tr_id} td", text: candidate.candidate_sheet.grade
      expect(rendered).to have_css "#{table_id} #{tr_id} td", text: candidate.candidate_sheet.attending
    end
    expect(rendered).to have_css "#{table_id} tr", count: @candidates.size + 1
    expect(rendered).to have_css("input[id='bottom-update'][type='submit'][value='#{t('views.common.update')}']")

  end

  def create_candidate(first_name, last_name)
    candidate = FactoryGirl.create(:candidate, account_name: "#{first_name.downcase}#{last_name.downcase}")
    # candidate = Candidate.find(candidate.id)
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

end