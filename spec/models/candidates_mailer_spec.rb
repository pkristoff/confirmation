include ViewsHelpers

describe CandidatesMailer, type: :model do

  before(:each) do
    candidate = create_candidate('Paul', 'Kristoff')
    AppFactory.add_confirmation_events
    @candidate = Candidate.find_by_account_name(candidate.account_name)
  end

  describe 'monthly_reminder' do
    it 'should create a mail form' do

      coming_due_values = @candidate.candidate_events.map do |ce|
        [ce.name, ce.id, ce.due_date]
      end

      mail = CandidatesMailer.monthly_reminder(@candidate, 'Confirmation - override',
                                               I18n.t('email.late_initial_text'),
                                               I18n.t('email.coming_due_initial_text'),
                                               I18n.t('email.completed_initial_text'),
                                               I18n.t('email.closing_initial_text'),
                                               I18n.t('email.salutation_initial_text'),
                                               I18n.t('email.from_initial_text')
      )
      expect(mail.to).to eq(['paul@yyy.com', 'test@example.com'])
      expect(mail.from).to eq(['vicki@kristoffs.com'])
      expect(mail.reply_to).to eq(['stmm.confirmation@kristoffs.com'])
      expect(mail.subject).to eq('Confirmation - override')

      body = Capybara.string(mail.body.encoded)

      expect_view(body, [], coming_due_values, [])

      expect(body).to have_css('p[id=closing_text]', text: '')
      expect(body).to have_css('p[id=salutation_text]', text: 'thanks')
      expect(body).to have_css('p[id=from_text]', text: 'Vicki')

    end
  end

  def expect_view(body, late_values, coming_due_values, completed_values)

    expect(body).to have_selector('p', text: "#{@candidate.candidate_sheet.first_name},")

    expect_table(body, I18n.t('email.pre_late_label'), I18n.t('email.late_initial_text'), 'late_events',
                 [I18n.t('email.late_events')],
                 late_values)

    expect_table(body, I18n.t('email.coming_due_label'), I18n.t('email.coming_due_initial_text'), 'coming_due_events',
                 [I18n.t('email.events'), I18n.t('email.due_date')],
                 coming_due_values)

    expect_table(body, I18n.t('email.completed_label'), I18n.t('email.completed_initial_text'), 'completed_events',
                 [I18n.t('email.completed_events'), I18n.t('email.verify')],
                 completed_values)
  end


  def expect_table(body, field_id, field_text, event_prefix, column_headers, cell_values)
    expect(body).to have_css("p[id='#{event_prefix}_text']", text: field_text) if expect(body).to have_field(field_id, text: field_text) unless table_id = "table[id='#{event_prefix}_table']"
    tr_header_id = "tr[id='#{event_prefix}_header']"

    expect(body).to have_css("#{table_id}")
    expect(body).to have_css("#{table_id} #{tr_header_id}")
    expect(body).to have_css "#{table_id} #{tr_header_id} th", count: column_headers.size
    column_headers.each do |header|
      expect(body).to have_css "#{table_id} #{tr_header_id} th", text: header
    end

    expect(body).to have_css("#{table_id} tr", count: cell_values.size+1)
    cell_values.each do |values|
      tr_td_id = "tr[id='#{event_prefix}_tr#{values[1]}']"
      tr_td_0_id = "td[id='#{event_prefix}_td0#{values[1]}']"
      tr_td_1_id = "td[id='#{event_prefix}_td1#{values[1]}']"
      tr_li_ul_id = "ul[id='#{event_prefix}_ul#{values[1]}']"

      expect(body).to have_css("#{table_id} #{tr_td_id} #{tr_td_0_id}", text: values[0])
      verifiable_info = values[2]
      if verifiable_info.is_a? Array
        expect(body).to have_css("#{tr_li_ul_id} li", count: verifiable_info.size)
        verifiable_info.each do |info|
          expect(body).to have_css("#{tr_li_ul_id} li", text: "#{info[0]}: #{info[1]}")
        end
      else
        if verifiable_info.nil?
          expect(body).not_to have_css("#{table_id} #{tr_td_id} #{tr_td_1_id}", text: verifiable_info)
        else
          expect(body).to have_css("#{table_id} #{tr_td_id} #{tr_td_1_id}", text: verifiable_info)
        end
      end
    end
  end

end