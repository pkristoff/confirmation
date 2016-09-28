

shared_context 'shared_monthly_reminder_html_erb' do

  today = Date.today.to_s

  before(:each) do

    candidate = FactoryGirl.create(:candidate)
    AppFactory.add_confirmation_events
    @candidate = Candidate.find(candidate.id)
    @candidate.candidate_sheet.candidate_email = 'xxx@yyy.com'
    @candidate.save

  end

  it 'display with all late' do

    set_due_date(Date.today-2)

    set_completed_date('')

    late_values = @candidate.candidate_events.map do |ce|
      [ce.name, ce.id, I18n.t('email.past_due')]
    end

    render_setup

    render

    expect_view(late_values, [], [], [])
  end

  it 'display with all coming due' do

    set_due_date(Date.today+1)

    set_completed_date('')

    render_setup

    coming_due_values = @candidate.candidate_events.map do |ce|
      [ce.name, ce.id, ce.due_date]
    end

    render

    expect_view([], [], coming_due_values, [])
  end

  it 'display with all completed' do

    completed_values = @candidate.candidate_events.map do |ce|
      ce.verified = true
      ce.completed_date = today
      [ce.name, ce.id, 'a: a']
    end

    render_setup

    render

    expect_view([], [], [], completed_values)
  end

  it 'display with mixture of events' do

    render_setup

    render

    late_events_event = @candidate.get_candidate_event('Going out to eat')
    verify_candidate_event = @candidate.get_candidate_event('Staying home')
    coming_due_values = AppFactory.all_i18n_confirmation_event_names.map do |i18n_name|
      name = I18n.t(i18n_name)
      id = @candidate.get_candidate_event(name).id
      [name, id, today]
    end

    expect_view([[late_events_event.name, late_events_event.id, I18n.t('email.past_due')]],
                [[verify_candidate_event.name, verify_candidate_event.id, 'a: a']],
                coming_due_values,
                [])
  end

  def expect_view(late_values, verify_values, coming_due_values, completed_values)
    unless @render_mail_text
      expect(rendered).to have_selector('p', text: "To: xxx@yyy.com, test@example.com, ")
      expect(rendered).to have_selector('p', text: "From: confirmation@kristoffs.com")
      expect(rendered).to have_selector('p', text: "Subject: Confirmation")
    end

    expect(rendered).to have_selector('p', text: "#{@candidate.candidate_sheet.first_name},")

    expect_table(I18n.t('email.pre_late_label'), t('email.late_initial_text'), 'late_events',
                 [I18n.t('email.late_events'), I18n.t('email.past_due')],
                 late_values)

    expect_table(I18n.t('email.coming_due_label'), t('email.coming_due_initial_text'), 'coming_due_events',
                 [I18n.t('email.events'), I18n.t('email.due_date')],
                 coming_due_values)

    expect_table(I18n.t('email.completed_label'), t('email.completed_initial_text'), 'completed_events',
                 [I18n.t('email.completed_events'), I18n.t('email.verify')],
                 completed_values)
  end


  def expect_table(field_id, field_text, event_prefix, column_headers, cell_values)
    expect(rendered).to have_css("p[id='#{event_prefix}_text']", text: field_text) if
    expect(rendered).to have_field(field_id, text: field_text) unless

    table_id = "table[id='#{event_prefix}_table']"
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
      expect(rendered).to have_css("#{table_id} #{tr_td_id} td", text: values[0])
      expect(rendered).to have_css("#{table_id} #{tr_td_id} td", text: values[2])
    end
  end

  def render_setup
    @pre_late_text = I18n.t('email.late_initial_text')
    @pre_verify_text = I18n.t('email.verify_initial_text')
    @pre_coming_due_text = I18n.t('email.coming_due_initial_text')
    @completed_text = I18n.t('email.completed_initial_text')

    @late_events = @candidate.get_late_events
    @verify_events = @candidate.get_verify_events
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