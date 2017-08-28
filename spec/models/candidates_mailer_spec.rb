include ViewsHelpers

describe CandidatesMailer, type: :model do


  # these should be the same for both tests
  LATE_INITIAL_TEXT = I18n.t('email.late_initial_text')
  COMING_DUE_INITIAL_TEXT = I18n.t('email.coming_due_initial_text')
  COMPLETE_INITIAL_TEXT = I18n.t('email.completed_initial_text')
  CLOSING_INITIAL_TEXT = I18n.t('email.closing_initial_text')
  SALUTATION_INITIAL_TEXT = I18n.t('email.salutation_initial_text')
  FROM_EMAIL_TEXT = I18n.t('email.from_initial_text')
  FROM_EMAIL = 'vicki@kristoffs.com'.freeze
  REPLY_TO_EMAIL = 'stmm.confirmation@kristoffs.com'.freeze
  SUBJECT = I18n.t('email.subject_initial_text')


  describe 'monthly_reminder testing' do

    before(:each) do
      candidate = create_candidate('Paul', 'Richard', 'Kristoff')
      AppFactory.add_confirmation_events
      @candidate = Candidate.find_by_account_name(candidate.account_name)
      @text = CandidatesMailerText.new(candidate: @candidate, subject: SUBJECT, pre_late_text: LATE_INITIAL_TEXT,
                                       pre_coming_due_text: COMING_DUE_INITIAL_TEXT,
                                       completed_text: COMPLETE_INITIAL_TEXT, closing_text: CLOSING_INITIAL_TEXT,
                                       salutation_text: SALUTATION_INITIAL_TEXT, from_text: FROM_EMAIL_TEXT)

    end
    describe 'monthly_reminder' do
      it 'should create a mail form' do

        admin = AppFactory.create_admin(email: 'candidate@example.com')

        coming_due_values = @candidate.candidate_events.map do |ce|
          [ce.name, ce.id, ce.due_date]
        end

        mail = CandidatesMailer.monthly_reminder(admin, @text)
        expect(mail.to).to eq([@candidate.candidate_sheet.candidate_email, @candidate.candidate_sheet.parent_email_1])
        expect(mail.from).to eq([FROM_EMAIL])
        expect(mail.reply_to).to eq([REPLY_TO_EMAIL])
        expect(mail.subject).to eq(SUBJECT)

        body = Capybara.string(mail.body.encoded)

        expect_view(body, [], coming_due_values, [])

        expect(body).to have_css('p[id=late_events_text][ style="white-space: pre-line;"]', text: LATE_INITIAL_TEXT)
        expect(body).to have_css('p[id=coming_due_events_text][ style="white-space: pre-line;"]', text: COMING_DUE_INITIAL_TEXT)
        expect(body).to have_css('p[id=completed_events_text][ style="white-space: pre-line;"]', text: COMPLETE_INITIAL_TEXT)
        expect(body).to have_css('p[id=closing_text][ style="white-space: pre-line;"]', text: CLOSING_INITIAL_TEXT)
        expect(body).to have_css('p[id=salutation_text][ style="white-space: pre-line;"]', text: 'thanks')
        expect(body).to have_css('p[id=from_text][ style="white-space: pre-line;"]', text: 'Vicki')

      end
    end

    describe 'monthly_reminder_test' do
      it 'should create a mail form' do

        admin = AppFactory.create_admin(email: 'candidate@example.com')

        coming_due_values = @candidate.candidate_events.map do |ce|
          [ce.name, ce.id, ce.due_date]
        end

        mail = CandidatesMailer.monthly_reminder_test(admin, @text)
        expect(mail.to).to eq([admin.email])
        expect(mail.from).to eq([FROM_EMAIL])
        expect(mail.reply_to).to eq([REPLY_TO_EMAIL])
        expect(mail.subject).to eq(I18n.t('email.test_mail_subject_initial_text', candidate_account_name: @candidate.account_name))

        body = Capybara.string(mail.body.encoded)

        expect(body).to have_css('li[id=candidate-email]', text: @candidate.candidate_sheet.candidate_email)
        expect(body).to have_css('li[id=parent-email-1]', text: @candidate.candidate_sheet.parent_email_1)
        expect(body).to have_css('li[id=parent-email-2]', text: @candidate.candidate_sheet.parent_email_2)

        expect(body).to have_css('p[id=subject]', text: SUBJECT)

        expect_view(body, [], coming_due_values, [])

        expect(body).to have_css('p[id=closing_text][ style="white-space: pre-line;"]', text: '')
        expect(body).to have_css('p[id=salutation_text][ style="white-space: pre-line;"]', text: 'thanks')
        expect(body).to have_css('p[id=from_text][ style="white-space: pre-line;"]', text: 'Vicki')

      end
    end

  end
  describe 'adhoc mail' do

    before(:each) do
      candidate = create_candidate('Paul', 'Richard', 'Kristoff')
      AppFactory.add_confirmation_events
      @candidate = Candidate.find_by_account_name(candidate.account_name)
      @text = CandidatesMailerText.new(candidate: @candidate, subject: SUBJECT, body_text: 'some body')

    end
    describe 'adhoc' do

      it 'should create an adhoc mail form' do

        admin = AppFactory.create_admin(email: 'candidate@example.com')

        mail = CandidatesMailer.adhoc(admin, @text)
        expect(mail.to).to eq([@candidate.candidate_sheet.candidate_email,@candidate.candidate_sheet.parent_email_1])
        expect(mail.from).to eq([FROM_EMAIL])
        expect(mail.reply_to).to eq([REPLY_TO_EMAIL])
        expect(mail.subject).to eq(SUBJECT)

        body = Capybara.string(mail.body.encoded)

        expect(body).to have_css('p[id=first_name]', text: 'Paul,')
        expect(body).to have_css('p[id=body_text][ style="white-space: pre-line;"]', text: 'some body')

      end
    end
    describe 'adhoc test' do

      it 'should create an adhoc test mail form' do

        admin = AppFactory.create_admin(email: 'candidate@example.com')

        mail = CandidatesMailer.adhoc_test(admin, @text)
        expect(mail.to).to eq([admin.email])
        expect(mail.from).to eq([FROM_EMAIL])
        expect(mail.reply_to).to eq([REPLY_TO_EMAIL])
        expect(mail.subject).to eq(I18n.t('email.test_adhoc_subject_initial_text', candidate_account_name: @candidate.account_name))

        body = Capybara.string(mail.body.encoded)

        expect(body).to have_css('li[id=candidate-email]', text: @candidate.candidate_sheet.candidate_email)
        expect(body).to have_css('li[id=parent-email-1]', text: @candidate.candidate_sheet.parent_email_1)
        expect(body).to have_css('li[id=parent-email-2]', text: '')

        expect(body).to have_css('p[id=subject]', text: "The subject: #{SUBJECT}")


        expect(body).to have_css('p[id=first_name]', text: 'Paul,')
        expect(body).to have_css('p[id=body_text]', text: 'some body')

      end
    end
  end

  def expect_view(body, late_values, coming_due_values, completed_values)

    expect(body).to have_selector('p', text: "#{@candidate.candidate_sheet.first_name},")

    expect_table(body, I18n.t('email.pre_late_label'), LATE_INITIAL_TEXT, 'late_events',
                 [I18n.t('email.late_events')],
                 late_values)

    expect_table(body, I18n.t('email.coming_due_label'), COMING_DUE_INITIAL_TEXT, 'coming_due_events',
                 [I18n.t('email.events'), I18n.t('email.due_date')],
                 coming_due_values)

    expect_table(body, I18n.t('email.completed_label'), COMPLETE_INITIAL_TEXT, 'completed_events',
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