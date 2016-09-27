
def response_setup
  @late_events = @candidate.get_late_events
  @verify_events = @candidate.get_verify_events
  @coming_due_events = @candidate.get_coming_due_events
  @completed_events = @candidate.get_completed
end

describe 'admins/email_candidate.html.erb' do

  today = Date.today.to_s

  before(:each) do

    candidate = FactoryGirl.create(:candidate)
    AppFactory.add_confirmation_events
    @candidate = Candidate.find(candidate.id)
    @candidate.candidate_sheet.candidate_email = 'xxx@yyy.com'
    @candidate.save

  end

  it 'display with all late' do

    @candidate.candidate_events.each do |ce|
      ce.verified=false
      ce.completed_date = ''
    end

    ConfirmationEvent.all.each do |ce|
      # puts "xxx: #{ce.name}: #{ce.chs_due_date}"
      yesterday = Date.today-1
      ce.chs_due_date = yesterday
      ce.the_way_due_date = yesterday
      ce.save
      # puts "yyy: #{ce.name}: #{ce.chs_due_date}"
    end

    response_setup

    late_values = @candidate.candidate_events.map do |ce|
      [ce.name, ce.id, I18n.t('email.past_due')]
    end
    render

    expect_view(late_values, [],[],  [])
  end

  it 'display with all verify' do

    @candidate.candidate_events.each do |ce|
      ce.verified=false
      ce.completed_date = Date.today
    end

    response_setup

    verify_values = @candidate.candidate_events.map do |ce|
      [ce.name, ce.id, 'a: a']
    end
    render

    expect_view([], verify_values,[],  [])
  end

  it 'display with all coming due' do

    ConfirmationEvent.all.each do |ce|
      # puts "xxx: #{ce.name}: #{ce.chs_due_date}"
      yesterday = Date.today+1
      ce.chs_due_date = yesterday
      ce.the_way_due_date = yesterday
      ce.save
      # puts "yyy: #{ce.name}: #{ce.chs_due_date}"
    end

    @candidate.candidate_events.each do |ce|
      ce.completed_date = ''
    end

    response_setup

    coming_due_values = @candidate.candidate_events.map do |ce|
      [ce.name, ce.id, ce.due_date]
    end

    # @coming_due_events.each {|ce| puts "#{ce.name}: #{ce.confirmation_event.chs_due_date}: #{ce.completed_date}"}

    render

    expect_view([], [], coming_due_values, [])
  end

  it 'display with all completed' do

    tr_values = @candidate.candidate_events.map do |ce|
      ce.verified = true
      ce.completed_date = today
      [ce.name, ce.id, I18n.t('email.completed_events')]
    end

    response_setup

    render

    expect_view([], [], [], tr_values)
  end

  it 'display with mixture of events' do

    response_setup

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
    expect(rendered).to have_selector('p', text: "To: xxx@yyy.com, test@example.com, ")
    expect(rendered).to have_selector('p', text: "From: confirmation@kristoffs.com")
    expect(rendered).to have_selector('p', text: "Subject: Confirmation")
    expect(rendered).to have_selector('p', text: "#{@candidate.candidate_sheet.first_name},")

    expect_table(I18n.t('email.pre_late_label'), t('email.late_initial_text'), 'late_events',
                 [I18n.t('email.late_events'), I18n.t('email.past_due')],
                 late_values)

    expect_table(I18n.t('email.pre_verify_label'), t('email.verify_initial_text'), 'verify_events',
                 [I18n.t('email.events'), I18n.t('email.verify')],
                 verify_values)

    expect_table(I18n.t('email.coming_due_label'), t('email.coming_due_initial_text'), 'coming_due_events',
                 [I18n.t('email.events'), I18n.t('email.due_date')],
                 coming_due_values)

    expect_table(I18n.t('email.completed_label'), t('email.completed_initial_text'), 'completed_events',
                 [I18n.t('email.completed_events'), I18n.t('email.due_date')],
                 completed_values)
  end


  def expect_table(field_id, field_text, event_prefix, column_headers, cell_values)
    expect(rendered).to have_field(field_id, text: field_text)

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

end
