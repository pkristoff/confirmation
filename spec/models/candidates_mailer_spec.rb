# frozen_string_literal: true

describe CandidatesMailer do
  include ViewsHelpers
  describe 'monthly_reminder testing' do
    before do
      AppFactory.generate_default_status
      admin = FactoryBot.create(:admin)
      candidate = create_candidate('Paul', 'Richard', 'Kristoff')
      AppFactory.add_confirmation_events
      @candidate = Candidate.find_by(account_name: candidate.account_name)
      @text = CandidatesMailerText.new(
        candidate: @candidate, subject: MailPart.new_subject(ViewsHelpers::SUBJECT),
        body_text: { pre_late_input: MailPart.new_pre_late_input(I18n.t('email.late_initial_input')),
                     pre_coming_due_input: MailPart.new_pre_coming_due_input(I18n.t('email.coming_due_initial_input')),
                     completed_awaiting_input: MailPart.new_completed_awaiting_input(
                       I18n.t('email.completed_awaiting_initial_input')
                     ),
                     completed_input: MailPart.new_completed_input(I18n.t('email.completed_initial_input')),
                     closing_input: MailPart.new_closing_input(ViewsHelpers::CLOSING_INITIAL_INPUT),
                     salutation_input: MailPart.new_salutation_input(I18n.t('email.salutation_initial_input')),
                     from_input: MailPart.new_from_input(I18n.t(ViewsHelpers::FROM_EMAIL_INPUT_I18N,
                                                                name: admin.contact_name,
                                                                email: admin.email,
                                                                phone: admin.contact_phone)) }
      )
    end

    describe 'monthly_reminder' do
      it 'create a mail form' do
        admin = AppFactory.create_admin(email: 'candidate@example.com',
                                        contact_name: 'Vicki Kristoff',
                                        contact_phone: '919-911-9191')

        coming_due_values = @candidate.candidate_events.map do |ce|
          [ce.event_key, ce.id, ce.due_date]
        end

        mail = CandidatesMailer.monthly_reminder(admin, @text)
        expect(mail.to).to eq([@candidate.candidate_sheet.candidate_email, @candidate.candidate_sheet.parent_email_1])
        expect(mail.from).to eq([I18n.t(ViewsHelpers::FROM_EMAIL_I18N, email: admin.email)])
        expect(mail.reply_to).to eq([I18n.t(ViewsHelpers::REPLY_TO_EMAIL_I18N, email: admin.email)])
        expect(mail.subject).to eq(ViewsHelpers::SUBJECT)

        body = Capybara.string(mail.body.encoded)

        expect_view(body, [], coming_due_values, [], [])

        expect(body).to have_css('p[id=past_due_input][ style="white-space: pre;"]',
                                 text: I18n.t('email.late_initial_input'))
        expect(body).to have_css('p[id=coming_due_events_input][ style="white-space: pre;"]',
                                 text: I18n.t('email.coming_due_initial_input'))
        expect_closing(body)
      end
    end

    describe 'monthly_reminder_test' do
      it 'create a mail form' do
        admin = AppFactory.create_admin(email: 'candidate@example.com')

        coming_due_values = @candidate.candidate_events.map do |ce|
          [ce.event_key, ce.id, ce.due_date]
        end

        mail = CandidatesMailer.monthly_reminder_test(admin, @text)
        expect(mail.to).to eq([admin.email])
        expect(mail.from).to eq([I18n.t(ViewsHelpers::FROM_EMAIL_I18N, email: admin.email)])
        expect(mail.reply_to).to eq([I18n.t(ViewsHelpers::REPLY_TO_EMAIL_I18N, email: admin.email)])
        expect(mail.subject).to eq(I18n.t('email.test_monthly_mail_subject_initial_input',
                                          candidate_account_name: @candidate.account_name))

        body = Capybara.string(mail.body.encoded)

        expect(body).to have_css('li[id=candidate-email]', text: @candidate.candidate_sheet.candidate_email)
        expect(body).to have_css('li[id=parent-email-1]', text: @candidate.candidate_sheet.parent_email_1)
        expect(body).to have_css('li[id=parent-email-2]', text: @candidate.candidate_sheet.parent_email_2)

        expect(body).to have_css('p[id=subject]', text: ViewsHelpers::SUBJECT)

        expect_view(body, [], coming_due_values, [], [])

        expect_closing(body)
      end
    end
  end

  describe 'adhoc mail' do
    before do
      AppFactory.generate_default_status
      candidate = create_candidate('Paul', 'Richard', 'Kristoff')
      AppFactory.add_confirmation_events
      @candidate = Candidate.find_by(account_name: candidate.account_name)
      @admin = AppFactory.create_admin(email: 'candidate@example.com')
      @text = CandidatesMailerText.new(candidate: @candidate,
                                       subject: MailPart.new_subject(ViewsHelpers::SUBJECT),
                                       body_text: MailPart.new_body('some body'),
                                       admin: @admin)
    end

    describe 'adhoc' do
      it 'create an adhoc mail form' do
        mail = CandidatesMailer.adhoc(@admin, @text)
        expect(mail.to).to eq([@candidate.candidate_sheet.candidate_email, @candidate.candidate_sheet.parent_email_1])
        expect(mail.from).to eq([I18n.t(ViewsHelpers::FROM_EMAIL_I18N, email: @admin.email)])
        expect(mail.reply_to).to eq([I18n.t(ViewsHelpers::REPLY_TO_EMAIL_I18N, email: @admin.email)])
        expect(mail.subject).to eq(ViewsHelpers::SUBJECT)

        body = Capybara.string(mail.body.encoded)

        expect(body).to have_css('p[id=first_name]', text: 'Paul,')
        expect(body).to have_css('p[id=body_text][ style="white-space: pre;"]', text: 'some body')
      end
    end

    describe 'adhoc test' do
      it 'create an adhoc test mail form' do
        admin = AppFactory.create_admin(email: 'candidate@example.com')

        mail = CandidatesMailer.adhoc_test(admin, @text)
        expect(mail.to).to eq([admin.email])
        expect(mail.from).to eq([I18n.t(ViewsHelpers::FROM_EMAIL_I18N, email: admin.email)])
        expect(mail.reply_to).to eq([I18n.t(ViewsHelpers::REPLY_TO_EMAIL_I18N, email: admin.email)])
        expect(mail.subject).to eq(I18n.t('email.test_adhoc_subject_initial_input',
                                          candidate_account_name: @candidate.account_name))

        body = Capybara.string(mail.body.encoded)

        expect(body).to have_css('li[id=candidate-email]', text: @candidate.candidate_sheet.candidate_email)
        expect(body).to have_css('li[id=parent-email-1]', text: @candidate.candidate_sheet.parent_email_1)
        expect(body).to have_css('li[id=parent-email-2]', text: '')

        expect(body).to have_css('p[id=subject]', text: "The subject: #{ViewsHelpers::SUBJECT}")

        expect(body).to have_css('p[id=first_name]', text: 'Paul,')
        expect(body).to have_css('p[id=body_text]', text: 'some body')
      end
    end
  end

  private

  def expect_view(body, late_values, coming_due_values, completed_awaiting_values, completed_values)
    expect(body).to have_selector('p', text: "#{@candidate.candidate_sheet.first_name},")

    expect_table(body, 'past_due_input', I18n.t('email.late_initial_input'), 'past_due',
                 [],
                 late_values)

    expect_table(body, I18n.t('email.coming_due_label'), I18n.t('email.coming_due_initial_input'), 'coming_due_events',
                 [I18n.t('email.events'), I18n.t('email.due_date')],
                 coming_due_values)

    expect_table(body, I18n.t('email.completed_awaiting_input_label'), I18n.t('email.completed_awaiting_initial_input'),
                 'completed_awaiting_events',
                 [I18n.t('email.completed_events'), I18n.t('email.information_entered')],
                 completed_awaiting_values)

    expect_table(body, I18n.t('email.completed_input_label'), I18n.t('email.completed_initial_input'), 'completed_events',
                 [I18n.t('email.completed_events'), I18n.t('email.information_entered')],
                 completed_values)
  end

  def expect_table(body, _field_id, field_text, event_prefix, column_headers, cell_values)
    table_id = "table[id='#{event_prefix}_table']"
    expect(body).to have_css("p[id='#{event_prefix}_input']", text: field_text) unless field_text.nil?
    tr_header_id = "tr[id='#{event_prefix}_header']"

    return expect(body).not_to have_css(table_id.to_s) if cell_values.empty?

    expect(body).to have_css(table_id.to_s)
    expect(body).to have_css("#{table_id} #{tr_header_id}")
    expect(body).to have_css "#{table_id} #{tr_header_id} th", count: column_headers.size
    column_headers.each do |header|
      expect(body).to have_css "#{table_id} #{tr_header_id} th", text: header
    end

    expect(body).to have_css("#{table_id} tr", count: cell_values.size + 1)
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
      elsif verifiable_info.nil?
        expect(body).not_to have_css("#{table_id} #{tr_td_id} #{tr_td_1_id}", text: verifiable_info)
      else
        expect(body).to have_css("#{table_id} #{tr_td_id} #{tr_td_1_id}", text: verifiable_info)
      end
    end
  end

  def expect_closing(body)
    expect(body).to have_css('p[id=closing_input][ style="white-space: pre;"]', text: '')
    expect(body).to have_css('p[id=salutation_input][ style="white-space: pre;"]', text: I18n.t('email.salutation_initial_input'))
    expect(body).to have_css('p[id=from_input][ style="white-space: pre;"]', text: 'Vicki Kristoff')
  end
end
