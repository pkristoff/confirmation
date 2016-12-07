
describe 'candidates_mailer/monthly_reminder.html.erb' do

  today = Date.today.to_s

  before(:each) do
    @render_mail_text = true

    candidate = FactoryGirl.create(:candidate)
    AppFactory.add_confirmation_events
    @candidate = Candidate.find(candidate.id)
    @candidate.candidate_sheet.candidate_email = 'xxx@yyy.com'

    @candidate.baptismal_certificate.birth_date = '1999-03-05'
    @candidate.baptismal_certificate.baptismal_date = '1999-05-05'
    @candidate.baptismal_certificate.father_first = 'A'
    @candidate.baptismal_certificate.father_middle = 'B'
    @candidate.baptismal_certificate.father_last = 'C'
    @candidate.baptismal_certificate.mother_first = 'Z'
    @candidate.baptismal_certificate.mother_middle = 'Y'
    @candidate.baptismal_certificate.mother_maiden = 'X'
    @candidate.baptismal_certificate.mother_last = 'W'
    @candidate.baptismal_certificate.church_name = 'St Pete'
    @candidate.baptismal_certificate.church_address.street_1 = 'The Holy Way'
    @candidate.baptismal_certificate.church_address.street_2 = ''
    @candidate.baptismal_certificate.church_address.city = 'Very Wet City'
    @candidate.baptismal_certificate.church_address.state = 'HA'
    @candidate.baptismal_certificate.church_address.zip_code = '12345'

    @candidate.sponsor_covenant.sponsor_name = 'The Boss'
    @candidate.sponsor_covenant.sponsor_attends_stmm = true

    @candidate.pick_confirmation_name.saint_name = 'Bolt'

    @candidate.save

  end

  it 'display with all late' do

    set_due_date(Date.today-2)

    set_completed_date('')

    late_values = @candidate.candidate_events.map do |ce|
      [ce.name, ce.id, nil]
    end

    render_setup

    render

    expect_view(late_values, [], [])
  end

  it 'display with all coming due' do

    set_due_date(Date.today+1)

    set_completed_date('')

    render_setup

    coming_due_values = @candidate.candidate_events.map do |ce|
      [ce.name, ce.id, ce.due_date]
    end

    render

    expect_view([], coming_due_values, [])
  end

  it 'display with all completed' do

    completed_values = @candidate.candidate_events.map do |ce|
      ce.verified = true
      ce.completed_date = today
      info = []
      case ce.name
        when I18n.t('events.confirmation_name')
          info << ['Confirmation name', 'Bolt']
        when I18n.t('events.sponsor_covenant')
          info << ['Sponsor name', 'The Boss']
          info << ['Sponsor attends', 'St. Mary Magdalene']
        when I18n.t('events.baptismal_certificate')
          info << ['Birthday', '1999-03-05']
          info << ['Baptismal date', '1999-05-05']
          info << ['Father\'s name', 'A B C']
          info << ['Mother\'s name', 'Z Y X W']
          info << ['Church', 'St Pete']
          info << ['Street', 'The Holy Way']
          info << ['Street 2', '']
          info << ['City', 'Very Wet City']
          info << ['State', 'HA']
          info << ['Zip Code', '12345']
        when I18n.t('events.candidate_information_sheet')
          info << [:name, 'Sophia Agusta']
          info << [:grade, '10']
          info << [:street_1, '2120 Frissell Ave.']
          info << [:street_2, 'Apt. 456']
          info << [:city, 'Apex']
          info << [:state, 'NC']
          info << [:zipcode, '27502']
      end
      [ce.name, ce.id, info]
    end

    render_setup

    render

    expect_view([], [], completed_values)
  end

  it 'display with mixture of events' do

    late_events_event = @candidate.get_candidate_event(I18n.t('events.parent_meeting'))
    late_events_event.confirmation_event.chs_due_date = Date.today-2
    late_events_event.confirmation_event.the_way_due_date = Date.today-2
    late_events_event.save
    late_events_values = [[late_events_event.name, late_events_event.id]]

    completed_events_event = @candidate.get_candidate_event(I18n.t('events.retreat_weekend'))
    completed_events_event.completed_date = Date.today-2
    completed_events_event.verified = true
    completed_events_event.save
    completed_events_values = [[completed_events_event.name, completed_events_event.id, []]]

    render_setup

    render

    coming_due_values = AppFactory.all_i18n_confirmation_event_names.select { |i18n_name| i18n_name != 'events.parent_meeting' and i18n_name != 'events.retreat_weekend' }.map do |i18n_name|
      name = I18n.t(i18n_name)
      id = @candidate.get_candidate_event(name).id
      [name, id, today]
    end

    expect_view(late_events_values,
                coming_due_values,
                completed_events_values)
  end

  def expect_view(late_values, coming_due_values, completed_values)

    expect(rendered).to have_selector('p', text: "#{@candidate.candidate_sheet.first_name},")

    expect_table(I18n.t('email.pre_late_label'), t('email.late_initial_text'), 'late_events',
                 [I18n.t('email.late_events')],
                 late_values)

    expect_table(I18n.t('email.coming_due_label'), t('email.coming_due_initial_text'), 'coming_due_events',
                 [I18n.t('email.events'), I18n.t('email.due_date')],
                 coming_due_values)

    expect_table(I18n.t('email.completed_label'), t('email.completed_initial_text'), 'completed_events',
                 [I18n.t('email.completed_events'), I18n.t('email.verify')],
                 completed_values)

    expect(rendered).to have_css('p[id=closing_text]', text: '')
    expect(rendered).to have_css('p[id=salutation_text]', text: 'thanks')
    expect(rendered).to have_css('p[id=from_text]', text: 'Vicki')

  end


  def expect_table(field_id, field_text, event_prefix, column_headers, cell_values)
    expect(rendered).to have_css("p[id='#{event_prefix}_text']", text: field_text) if expect(rendered).to have_field(field_id, text: field_text) unless table_id = "table[id='#{event_prefix}_table']"
    tr_header_id = "tr[id='#{event_prefix}_header']"

    expect(rendered).to have_css("#{table_id}")
    expect(rendered).to have_css("#{table_id} #{tr_header_id}")
    expect(rendered).to have_css "#{table_id} #{tr_header_id} th", count: column_headers.size
    column_headers.each do |header|
      expect(rendered).to have_css "#{table_id} #{tr_header_id} th", text: header
    end

    expect(rendered).to have_css("#{table_id} tr", count: cell_values.size+1)
    cell_values.each do |values|
      tr_td_id = "tr[id='#{event_prefix}_tr#{values[1]}']"
      tr_td_0_id = "td[id='#{event_prefix}_td0#{values[1]}']"
      tr_td_1_id = "td[id='#{event_prefix}_td1#{values[1]}']"
      tr_li_ul_id = "ul[id='#{event_prefix}_ul#{values[1]}']"

      expect(rendered).to have_css("#{table_id} #{tr_td_id} #{tr_td_0_id}", text: values[0])
      verifiable_info = values[2]
      if verifiable_info.is_a? Array
        expect(rendered).to have_css("#{tr_li_ul_id} li", count: verifiable_info.size)
        verifiable_info.each do |info|
          expect(rendered).to have_css("#{tr_li_ul_id} li", text: "#{info[0]}: #{info[1]}")
        end
      else
        if verifiable_info.nil?
          expect(rendered).not_to have_css("#{table_id} #{tr_td_id} #{tr_td_1_id}", text: verifiable_info)
        else
          expect(rendered).to have_css("#{table_id} #{tr_td_id} #{tr_td_1_id}", text: verifiable_info)
        end
      end
    end
  end

  def render_setup
    @pre_late_text = I18n.t('email.late_initial_text')
    @pre_coming_due_text = I18n.t('email.coming_due_initial_text')
    @completed_text = I18n.t('email.completed_initial_text')
    @closing_text = I18n.t('email.closing_initial_text')
    @salutation_text = I18n.t('email.salutation_initial_text')
    @from_text = I18n.t('email.from_initial_text')

    @late_events = @candidate.get_late_events
    @coming_due_events = @candidate.get_coming_due_events
    @completed_events = @candidate.get_completed
  end

  def set_completed_date(date)
    @candidate.candidate_events.each do |ce|
      ce.verified=false
      ce.completed_date = date
      # puts "yyy: #{ce.name}: #{ce.due_date}"
    end
  end

  def set_due_date(date)
    ConfirmationEvent.all.each do |ce|
      # puts "xxx: #{ce.name}: #{ce.chs_due_date}"
      ce.chs_due_date = date
      ce.the_way_due_date = date
      ce.save
      # puts "yyy: #{ce.name}: #{ce.chs_due_date}"
    end
  end


end
