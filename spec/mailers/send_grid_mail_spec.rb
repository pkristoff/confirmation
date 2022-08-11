# frozen_string_literal: true

describe SendGridMail, type: :model do
  include ViewsHelpers

  before do
    FactoryBot.create(:visitor)
  end
  describe 'monthly_reminder testing' do
    before(:each) do
      @admin = FactoryBot.create(:admin)
      candidate = create_candidate('Paul', 'Richard', 'Kristoff')
      AppFactory.add_confirmation_events
      @candidate = Candidate.find_by(account_name: candidate.account_name)
    end

    it 'should expand the adhoc email for candidate with no attachment' do
      send_grid_mail = SendGridMailSpec.new(@admin, [@candidate])
      send_grid_mail.adhoc(MailPart.new_subject(ViewsHelpers::SUBJECT), nil,
                           MailPart.new_body(ViewsHelpers::COMPLETE_AWAITING_INITIAL_INPUT))

      body = Capybara.string(send_grid_mail.expanded_text)
      expect(body).to have_css('p[id=first_name]', text: @candidate.candidate_sheet.first_name)
      expect(body).to have_css('p[id=body_text]', text: ViewsHelpers::COMPLETE_AWAITING_INITIAL_INPUT)

      expect(send_grid_mail.attachments.empty?).to eq(true)
    end

    it 'should expand the adhoc email for candidate with attachment' do
      send_grid_mail = SendGridMailSpec.new(@admin, [@candidate])
      send_grid_mail.adhoc(MailPart.new_subject(ViewsHelpers::SUBJECT),
                           fixture_file_upload('Baptismal Certificate.pdf'),
                           MailPart.new_body(ViewsHelpers::COMPLETE_AWAITING_INITIAL_INPUT))

      body = Capybara.string(send_grid_mail.expanded_text)
      expect(body).to have_css('p[id=first_name]', text: @candidate.candidate_sheet.first_name)
      expect(body).to have_css('p[id=body_text]', text: ViewsHelpers::COMPLETE_AWAITING_INITIAL_INPUT)

      expect(send_grid_mail.attachments.size).to eq(1)
      attachment = send_grid_mail.attachments[0]
      expect(attachment['filename']).to eq('Baptismal Certificate.pdf')
    end

    it 'should expand the adhoc test email for candidate with no attachment' do
      send_grid_mail = SendGridMailSpec.new(@admin, [@candidate])
      send_grid_mail.adhoc_test(MailPart.new_subject(ViewsHelpers::SUBJECT), nil,
                                MailPart.new_body(ViewsHelpers::COMPLETE_AWAITING_INITIAL_INPUT))

      body = Capybara.string(send_grid_mail.expanded_text)
      expect(body).to have_css('li[id=candidate-email]', text: @candidate.candidate_sheet.candidate_email)
      expect(body).to have_css('li[id=parent-email-1]', text: @candidate.candidate_sheet.parent_email_1)
      expect(body).to have_css('li[id=parent-email-2]', text: @candidate.candidate_sheet.parent_email_2)
      expect(body).to have_css('p[id=subject]', text: ViewsHelpers::SUBJECT)

      expect(body).to have_css('p[id=first_name]', text: @candidate.candidate_sheet.first_name)
      expect(body).to have_css('p[id=body_text]', text: ViewsHelpers::COMPLETE_AWAITING_INITIAL_INPUT)

      expect(send_grid_mail.attachments.empty?).to eq(true)
    end

    it 'should expand the adhoc test email for candidate with attachment' do
      send_grid_mail = SendGridMailSpec.new(@admin, [@candidate])
      send_grid_mail.adhoc_test(MailPart.new_subject(ViewsHelpers::SUBJECT),
                                fixture_file_upload('Baptismal Certificate.pdf'),
                                MailPart.new_body(ViewsHelpers::COMPLETE_AWAITING_INITIAL_INPUT))

      body = Capybara.string(send_grid_mail.expanded_text)
      expect(body).to have_css('li[id=candidate-email]', text: @candidate.candidate_sheet.candidate_email)
      expect(body).to have_css('li[id=parent-email-1]', text: @candidate.candidate_sheet.parent_email_1)
      expect(body).to have_css('li[id=parent-email-2]', text: @candidate.candidate_sheet.parent_email_2)
      expect(body).to have_css('p[id=subject]', text: ViewsHelpers::SUBJECT)

      expect(body).to have_css('p[id=first_name]', text: @candidate.candidate_sheet.first_name)
      expect(body).to have_css('p[id=body_text]', text: ViewsHelpers::COMPLETE_AWAITING_INITIAL_INPUT)

      expect(send_grid_mail.attachments.size).to eq(1)
      attachment = send_grid_mail.attachments[0]
      expect(attachment['filename']).to eq('Baptismal Certificate.pdf')
    end

    it 'should expand the account confirmation instructions for candidate' do
      send_grid_mail = SendGridMail.new(@admin, [@candidate])
      text = send_grid_mail.expand_text_ci(@candidate)

      body = Capybara.string(text)
      expected_msg = "Welcome #{@candidate.candidate_sheet.first_name}  #{@candidate.candidate_sheet.last_name}"
      expect(body).to have_css('p[id=welcome]', text: expected_msg)
      expect_basic_candidate_info(body, @candidate)
      expect_basic_admin_info(body, 'Account%20confirmation%20instructions')
    end

    it 'should expand the monthly reminder email for candidate with no attachment' do
      # rubocop:disable Layout/LineLength
      send_grid_mail = SendGridMailSpec.new(@admin, [@candidate])
      send_grid_mail.monthly_mass_mailing(MailPart.new_subject(ViewsHelpers::SUBJECT),
                                          nil,
                                          pre_late_input: MailPart.new_pre_late_input(ViewsHelpers::LATE_INITIAL_INPUT),
                                          pre_coming_due_input: MailPart.new_pre_coming_due_input(ViewsHelpers::COMING_DUE_INITIAL_INPUT),
                                          completed_awaiting_input: MailPart.new_completed_awaiting_input(ViewsHelpers::COMPLETE_AWAITING_INITIAL_INPUT),
                                          completed_input: MailPart.new_completed_input(ViewsHelpers::COMPLETE_INITIAL_INPUT), closing_input: MailPart.new_closing_input(ViewsHelpers::CLOSING_INITIAL_INPUT),
                                          salutation_input: MailPart.new_salutation_input(ViewsHelpers::SALUTATION_INITIAL_INPUT),
                                          from_input: MailPart.new_from_input(I18n.t(ViewsHelpers::FROM_EMAIL_INPUT_I18N,
                                                                                     name: @admin.contact_name,
                                                                                     email: @admin.email,
                                                                                     phone: @admin.contact_phone)))

      body = Capybara.string(send_grid_mail.expanded_text)
      expect(body).to have_css('p[id=past_due_input]', text: ViewsHelpers::LATE_INITIAL_INPUT)
      expect(body).to have_css('p[id=coming_due_events_input]', text: ViewsHelpers::COMING_DUE_INITIAL_INPUT)
      expect(body).to have_css('p[id=completed_awaiting_events_input]', text: ViewsHelpers::COMPLETE_AWAITING_INITIAL_INPUT)
      expect(body).to have_css('p[id=closing_input]', text: ViewsHelpers::CLOSING_INITIAL_INPUT)
      expect(body).to have_css('p[id=completed_events_input]', text: ViewsHelpers::COMPLETE_INITIAL_INPUT)
      expect(body).to have_css('p[id=salutation_input]', text: ViewsHelpers::SALUTATION_INITIAL_INPUT)
      expect(body).to have_css('p[id=from_input]',
                               text: I18n.t(ViewsHelpers::FROM_EMAIL_INPUT_I18N,
                                            name: @admin.contact_name,
                                            email: @admin.email,
                                            phone: @admin.contact_phone))

      expect(send_grid_mail.attachments.empty?).to eq(true)
      # rubocop:enable Layout/LineLength
    end

    it 'should expand the monthly reminder email with file attachment for candidate' do
      # rubocop:disable Layout/LineLength
      send_grid_mail = SendGridMailSpec.new(@admin, [@candidate])
      send_grid_mail.monthly_mass_mailing(MailPart.new_subject(ViewsHelpers::SUBJECT),
                                          fixture_file_upload('Baptismal Certificate.pdf'),
                                          pre_late_input: MailPart.new_pre_late_input(ViewsHelpers::LATE_INITIAL_INPUT),
                                          pre_coming_due_input: MailPart.new_pre_coming_due_input(ViewsHelpers::COMING_DUE_INITIAL_INPUT),
                                          completed_awaiting_input: MailPart.new_completed_awaiting_input(ViewsHelpers::COMPLETE_AWAITING_INITIAL_INPUT),
                                          completed_input: MailPart.new_completed_input(ViewsHelpers::COMPLETE_INITIAL_INPUT), closing_input: MailPart.new_closing_input(ViewsHelpers::CLOSING_INITIAL_INPUT),
                                          salutation_input: MailPart.new_salutation_input(ViewsHelpers::SALUTATION_INITIAL_INPUT),
                                          from_input: MailPart.new_from_input(I18n.t(ViewsHelpers::FROM_EMAIL_INPUT_I18N,
                                                                                     name: @admin.contact_name,
                                                                                     email: @admin.email,
                                                                                     phone: @admin.contact_phone)))

      body = Capybara.string(send_grid_mail.expanded_text)
      expect(body).to have_css('p[id=past_due_input]', text: ViewsHelpers::LATE_INITIAL_INPUT)
      expect(body).to have_css('p[id=coming_due_events_input]', text: ViewsHelpers::COMING_DUE_INITIAL_INPUT)
      expect(body).to have_css('p[id=completed_awaiting_events_input]', text: ViewsHelpers::COMPLETE_AWAITING_INITIAL_INPUT)
      expect(body).to have_css('p[id=closing_input]', text: ViewsHelpers::CLOSING_INITIAL_INPUT)
      expect(body).to have_css('p[id=completed_events_input]', text: ViewsHelpers::COMPLETE_INITIAL_INPUT)
      expect(body).to have_css('p[id=salutation_input]', text: ViewsHelpers::SALUTATION_INITIAL_INPUT)
      expect(body).to have_css('p[id=from_input]',
                               text: I18n.t(ViewsHelpers::FROM_EMAIL_INPUT_I18N,
                                            name: @admin.contact_name,
                                            email: @admin.email,
                                            phone: @admin.contact_phone))

      expect(send_grid_mail.attachments.size).to eq(1)
      attachment = send_grid_mail.attachments[0]
      expect(attachment['filename']).to eq('Baptismal Certificate.pdf')
      # rubocop:enable Layout/LineLength
    end

    it 'should expand the reset password for candidate' do
      send_grid_mail = SendGridMail.new(@admin, [@candidate])
      text = send_grid_mail.expand_text_rp(@candidate)

      body = Capybara.string(text)
      expect(body).to have_css('p[id=welcome]', text: "Hello #{@candidate.account_name}")
      expect_basic_candidate_info(body, @candidate)
      expect_basic_admin_info(body, 'Reset%20password%20instructions')
    end
  end

  describe 'convert_if_not_production' do
    before(:each) do
      @admin = FactoryBot.create(:admin)
      candidate = create_candidate('Paul', 'Richard', 'Kristoff')
      AppFactory.add_confirmation_events
      @candidate = Candidate.find_by(account_name: candidate.account_name)
    end

    it 'should return nil' do
      send_grid_mail = SendGridMail.new(@admin, [@candidate])
      expect(send_grid_mail.convert_if_not_production(nil)).to be_nil
    end

    describe 'PIPELINE' do
      it 'should return PIPELINE=nil' do
        Rails.application.secrets.pipeline = nil
        send_grid_mail = SendGridMail.new(@admin, [@candidate])
        expect(send_grid_mail.convert_if_not_production(nil)).to be_nil
      end
      it 'should return PIPELINE=nil for convert_emails' do
        Rails.application.secrets.pipeline = nil
        send_grid_mail = SendGridMail.new(@admin, [@candidate])
        expect(send_grid_mail.convert_emails([nil], ['stmm.confirmation@kristoffs.com'])).to eq([nil])
      end

      it 'should return local email when multiple emails when PIPELINE=nil' do
        Rails.application.secrets.pipeline = nil
        send_grid_mail = SendGridMail.new(@admin, [@candidate])
        expect(send_grid_mail.convert_if_not_production('prk1@test.com')).to eq('paul@kristoffs.com')
        expect(send_grid_mail.convert_if_not_production('prk2@test.com')).to eq('paul.kristoff@kristoffs.com')
      end
      it 'should return local email when multiple emails when PIPELINE=nil for convert_emails' do
        Rails.application.secrets.pipeline = nil
        send_grid_mail = SendGridMail.new(@admin, [@candidate])
        # rubocop:disable Layout/LineLength
        expect(send_grid_mail.convert_emails(%w[prk1@test.com prk2@test.com], ['stmm.confirmation@kristoffs.com'])).to eq(%w[paul@kristoffs.com paul.kristoff@kristoffs.com])
        # rubocop:enable Layout/LineLength
      end

      it 'should return local email when multiple emails and one local when PIPELINE=nil' do
        # rubocop:disable Layout/LineLength
        Rails.application.secrets.pipeline = nil
        send_grid_mail = SendGridMail.new(@admin, [@candidate])
        expect(send_grid_mail.convert_if_not_production('paul@kristoffs.com', [], ['paul@kristoffs.com'])).to eq('paul@kristoffs.com')
        expect(send_grid_mail.convert_if_not_production('prk2@test.com', ['paul@kristoffs.com'], ['paul@kristoffs.com'])).to eq('paul.kristoff@kristoffs.com')
        # rubocop:enable Layout/LineLength
      end
      it 'should return local email when multiple emails and one local when PIPELINE=nil for convert_emails' do
        # rubocop:disable Layout/LineLength
        Rails.application.secrets.pipeline = nil
        send_grid_mail = SendGridMail.new(@admin, [@candidate])
        expect(send_grid_mail.convert_emails(%w[paul@kristoffs.com prk2@test.com], ['stmm.confirmation@kristoffs.com'])).to eq(%w[paul@kristoffs.com paul.kristoff@kristoffs.com])
        # rubocop:enable Layout/LineLength
      end

      it 'should return local email when multiple emails and one local when PIPELINE=nil' do
        Rails.application.secrets.pipeline = nil
        send_grid_mail = SendGridMail.new(@admin, [@candidate])
        expect(send_grid_mail.convert_if_not_production('paul.kristoff@kristoffs.com')).to eq('paul.kristoff@kristoffs.com')
        expect(send_grid_mail.convert_if_not_production('prk2@test.com')).to eq('paul@kristoffs.com')
      end
      it 'should return local email when multiple emails and one local when PIPELINE=nil for convert_emails' do
        Rails.application.secrets.pipeline = nil
        send_grid_mail = SendGridMail.new(@admin, [@candidate])
        # rubocop:disable Layout/LineLength
        expect(send_grid_mail.convert_emails(%w[paul.kristoff@kristoffs.com prk2@test.com], ['stmm.confirmation@kristoffs.com'])).to eq(%w[paul.kristoff@kristoffs.com paul@kristoffs.com])
        # rubocop:enable Layout/LineLength
      end

      it 'should return local email when PIPELINE=staging' do
        Rails.application.secrets.pipeline = 'staging'
        send_grid_mail = SendGridMail.new(@admin, [@candidate])
        expect(send_grid_mail.convert_if_not_production('prk@test.com')).to eq('paul@kristoffs.com')
      end
      it 'should return local email when PIPELINE=staging for convert_emails' do
        Rails.application.secrets.pipeline = 'staging'
        send_grid_mail = SendGridMail.new(@admin, [@candidate])
        expect(send_grid_mail.convert_emails(['prk@test.com'], ['stmm.confirmation@kristoffs.com'])).to eq(['paul@kristoffs.com'])
      end

      it 'should return local email when multiple emails when PIPELINE=staging' do
        Rails.application.secrets.pipeline = 'staging'
        send_grid_mail = SendGridMail.new(@admin, [@candidate])
        expect(send_grid_mail.convert_if_not_production('prk1@test.com')).to eq('paul@kristoffs.com')
        expect(send_grid_mail.convert_if_not_production('prk2@test.com')).to eq('paul.kristoff@kristoffs.com')
      end
      it 'should return local email when multiple emails when PIPELINE=staging for convert_emails' do
        Rails.application.secrets.pipeline = 'staging'
        send_grid_mail = SendGridMail.new(@admin, [@candidate])
        # rubocop:disable Layout/LineLength
        expect(send_grid_mail.convert_emails(%w[paul@kristoffs.com prk2@test.com], ['stmm.confirmation@kristoffs.com'])).to eq(%w[paul@kristoffs.com paul.kristoff@kristoffs.com])
        # rubocop:enable Layout/LineLength
      end

      it 'should return local email when multiple emails when PIPELINE=staging' do
        # rubocop:disable Layout/LineLength
        Rails.application.secrets.pipeline = 'staging'
        send_grid_mail = SendGridMail.new(@admin, [@candidate])
        expect(send_grid_mail.convert_if_not_production('camping@kristoffs.com', [], ['paul@kristoffs.com'])).to eq('paul.kristoff@kristoffs.com')
        expect(send_grid_mail.convert_if_not_production('paul@kristoffs.com', ['paul.kristoff@kristoffs.com'], ['paul@kristoffs.com'])).to eq('paul@kristoffs.com')
        expect(send_grid_mail.convert_if_not_production('medical@kristoffs.com', ['paul.kristoff@kristoffs.com', 'paul@kristoffs.com'], ['paul@kristoffs.com'])).to eq('retail@kristoffs.com')
        # rubocop:enable Layout/LineLength
      end
      it 'should return local email when multiple emails when PIPELINE=staging' do
        Rails.application.secrets.pipeline = 'staging'
        send_grid_mail = SendGridMail.new(@admin, [@candidate])
        # rubocop:disable Layout/LineLength
        expect(send_grid_mail.convert_emails(%w[camping@kristoffs.com paul@kristoffs.com medical@kristoffs.com], ['stmm.confirmation@kristoffs.com'])).to eq(%w[paul.kristoff@kristoffs.com paul@kristoffs.com retail@kristoffs.com])
        # rubocop:enable Layout/LineLength
      end

      it 'should return local email when multiple emails when PIPELINE=staging' do
        # rubocop:disable Layout/LineLength
        Rails.application.secrets.pipeline = 'staging'
        send_grid_mail = SendGridMail.new(@admin, [@candidate])
        expect(send_grid_mail.convert_if_not_production('prk1@test.com')).to eq('paul@kristoffs.com')
        expect(send_grid_mail.convert_if_not_production('retail@kristoffs.com', ['paul@kristoffs.com'])).to eq('retail@kristoffs.com')
        expect(send_grid_mail.convert_if_not_production('prk2@test.com', ['paul@kristoffs.com', 'retail@kristoffs.com'])).to eq('paul.kristoff@kristoffs.com')
        expect(send_grid_mail.convert_if_not_production('prk3@test.com', ['paul@kristoffs.com', 'retail@kristoffs.com', 'paul.kristoff@kristoffs.com'])).to eq('justfaith@kristoffs.com')
        # rubocop:enable Layout/LineLength
      end
      it 'should return local email when multiple emails when PIPELINE=staging for convert_emails' do
        Rails.application.secrets.pipeline = 'staging'
        send_grid_mail = SendGridMail.new(@admin, [@candidate])
        # rubocop:disable Layout/LineLength
        expect(send_grid_mail.convert_emails(%w[prk1@test.com retail@kristoffs.com prk2@test.com prk3@test.com], ['stmm.confirmation@kristoffs.com'])).to eq(%w[paul@kristoffs.com retail@kristoffs.com paul.kristoff@kristoffs.com justfaith@kristoffs.com])
        # rubocop:enable Layout/LineLength
      end

      it 'should return unchanged email when PIPELINE=production' do
        Rails.application.secrets.pipeline = 'production'
        send_grid_mail = SendGridMail.new(@admin, [@candidate])
        expect(send_grid_mail.convert_if_not_production('prk@test.com')).to eq('prk@test.com')
      end
      it 'should return unchanged email when PIPELINE=production for convert_emails' do
        Rails.application.secrets.pipeline = 'production'
        send_grid_mail = SendGridMail.new(@admin, [@candidate])
        expect(send_grid_mail.convert_emails(%w[prk@test.com], ['stmm.confirmation@kristoffs.com'])).to eq(%w[prk@test.com])
      end

      it 'should return nil when PIPELINE=production' do
        Rails.application.secrets.pipeline = 'production'
        send_grid_mail = SendGridMail.new(@admin, [@candidate])
        expect(send_grid_mail.convert_if_not_production(nil)).to be_nil
      end
      it 'should return nil when PIPELINE=production for convert_emails' do
        Rails.application.secrets.pipeline = 'production'
        send_grid_mail = SendGridMail.new(@admin, [@candidate])
        expect(send_grid_mail.convert_emails([nil], ['stmm.confirmation@kristoffs.com'])).to eq([nil])
      end

      it 'should return unchanged emails when multiple emails when PIPELINE=production' do
        Rails.application.secrets.pipeline = 'production'
        send_grid_mail = SendGridMail.new(@admin, [@candidate])
        expect(send_grid_mail.convert_if_not_production('prk1@test.com')).to eq('prk1@test.com')
        expect(send_grid_mail.convert_if_not_production('retail@test.com')).to eq('retail@test.com')
      end
      it 'should return unchanged emails when multiple emails when PIPELINE=production for convert_emails' do
        Rails.application.secrets.pipeline = 'production'
        send_grid_mail = SendGridMail.new(@admin, [@candidate])
        # rubocop:disable Layout/LineLength
        expect(send_grid_mail.convert_emails(%w[prk1@test.com retail@test.com], ['stmm.confirmation@kristoffs.com'])).to eq(%w[prk1@test.com retail@test.com])
        # rubocop:enable Layout/LineLength
      end
    end
  end

  describe 'categories' do
    it 'should have 4 categories' do
      admin = FactoryBot.create(:admin)
      candidate = create_candidate('Paul', 'Richard', 'Kristoff')
      send_grid_mail = SendGridMailSpec.new(admin, [candidate])
      mail = send_grid_mail.create_mail(MailPart.new_subject('subject text'),
                                        EmailStuff::TYPES[:adhoc],
                                        candidate.account_name)
      expect(mail.categories.size).to eq(4)
    end
    it 'should have 4 categories with values' do
      admin = FactoryBot.create(:admin)
      candidate = create_candidate('Paul', 'Richard', 'Kristoff')
      send_grid_mail = SendGridMailSpec.new(admin, [candidate])
      mail = send_grid_mail.create_mail(MailPart.new_subject('subject text'),
                                        EmailStuff::TYPES[:adhoc],
                                        candidate.account_name)
      expect(mail.categories[0]).to eq('test')
      expect(mail.categories[1]).to eq(EmailStuff::TYPES[:adhoc])
      expect(mail.categories[2]).to eq(candidate.account_name)
      expect(mail.categories[3]).to eq('subject text')
    end
  end

  describe 'show and hide' do
    before(:each) do
      @admin = FactoryBot.create(:admin)
      candidate = create_candidate('Paul', 'Richard', 'Kristoff')
      AppFactory.add_confirmation_events
      @candidate = Candidate.find_by(account_name: candidate.account_name)
    end
    describe 'adhoc' do
      it 'should expand the adhoc email for candidate with no body' do
        send_grid_mail = SendGridMailSpec.new(@admin, [@candidate])
        send_grid_mail.adhoc(MailPart.new_subject(ViewsHelpers::SUBJECT), nil,
                             MailPart.new_body(ViewsHelpers::COMPLETE_AWAITING_INITIAL_INPUT, { show: false }))

        body = Capybara.string(send_grid_mail.expanded_text)
        expect(body).to have_css('p[id=first_name]', text: @candidate.candidate_sheet.first_name)
        # key Test
        expect(body).not_to have_css('p[id=body_text]')

        expect(send_grid_mail.attachments.empty?).to eq(true)
      end
    end
    describe 'monthly mass mailing' do
      it 'should expand the monthly reminder email for candidate with no pre_late_input' do
        # rubocop:disable Layout/LineLength
        send_grid_mail = SendGridMailSpec.new(@admin, [@candidate])
        send_grid_mail.monthly_mass_mailing(MailPart.new_subject(ViewsHelpers::SUBJECT),
                                            nil,
                                            pre_late_input: MailPart.new_pre_late_input(ViewsHelpers::LATE_INITIAL_INPUT, { show: false }),
                                            pre_coming_due_input: MailPart.new_pre_coming_due_input(ViewsHelpers::COMING_DUE_INITIAL_INPUT),
                                            completed_awaiting_input: MailPart.new_completed_awaiting_input(ViewsHelpers::COMPLETE_AWAITING_INITIAL_INPUT),
                                            completed_input: MailPart.new_completed_input(ViewsHelpers::COMPLETE_INITIAL_INPUT), closing_input: MailPart.new_closing_input(ViewsHelpers::CLOSING_INITIAL_INPUT),
                                            salutation_input: MailPart.new_salutation_input(ViewsHelpers::SALUTATION_INITIAL_INPUT), from_input: MailPart.new_from_input(I18n.t(ViewsHelpers::FROM_EMAIL_INPUT_I18N, name: @admin.contact_name, email: @admin.email, phone: @admin.contact_phone)))

        body = Capybara.string(send_grid_mail.expanded_text)
        expect(body).not_to have_css('p[id=past_due_input]')
        expect(body).to have_css('p[id=coming_due_events_input]', text: ViewsHelpers::COMING_DUE_INITIAL_INPUT)
        expect(body).to have_css('p[id=completed_awaiting_events_input]', text: ViewsHelpers::COMPLETE_AWAITING_INITIAL_INPUT)
        expect(body).to have_css('p[id=closing_input]', text: ViewsHelpers::CLOSING_INITIAL_INPUT)
        expect(body).to have_css('p[id=completed_events_input]', text: ViewsHelpers::COMPLETE_INITIAL_INPUT)
        expect(body).to have_css('p[id=salutation_input]', text: ViewsHelpers::SALUTATION_INITIAL_INPUT)
        expect(body).to have_css('p[id=from_input]', text: I18n.t(ViewsHelpers::FROM_EMAIL_INPUT_I18N, name: @admin.contact_name, email: @admin.email, phone: @admin.contact_phone))

        expect(send_grid_mail.attachments.empty?).to eq(true)
        # rubocop:enable Layout/LineLength
      end
      it 'should expand the monthly reminder email for candidate with no entry for each MailPart' do
        # rubocop:disable Layout/LineLength
        %i[pre_late_input pre_coming_due_input completed_awaiting_input completed_input
           closing_input salutation_input from_input].each do |entry|
          send_grid_mail = SendGridMailSpec.new(@admin, [@candidate])
          send_grid_mail.monthly_mass_mailing(MailPart.new_subject(ViewsHelpers::SUBJECT),
                                              nil,
                                              pre_late_input: MailPart.new_pre_late_input(ViewsHelpers::LATE_INITIAL_INPUT, { show: entry != :pre_late_input }),
                                              pre_coming_due_input: MailPart.new_pre_coming_due_input(ViewsHelpers::COMING_DUE_INITIAL_INPUT, { show: entry != :pre_coming_due_input }),
                                              completed_awaiting_input: MailPart.new_completed_awaiting_input(ViewsHelpers::COMPLETE_AWAITING_INITIAL_INPUT, { show: entry != :completed_awaiting_input }),
                                              completed_input: MailPart.new_completed_input(ViewsHelpers::COMPLETE_INITIAL_INPUT, { show: entry != :completed_input }),
                                              closing_input: MailPart.new_closing_input(ViewsHelpers::CLOSING_INITIAL_INPUT, { show: entry != :closing_input }),
                                              salutation_input: MailPart.new_salutation_input(ViewsHelpers::SALUTATION_INITIAL_INPUT, { show: entry != :salutation_input }),
                                              from_input: MailPart.new_from_input(I18n.t(ViewsHelpers::FROM_EMAIL_INPUT_I18N, name: @admin.contact_name, email: @admin.email, phone: @admin.contact_phone)))

          body = Capybara.string(send_grid_mail.expanded_text)
          expect(body).to have_css('p[id=past_due_input]', text: ViewsHelpers::LATE_INITIAL_INPUT) unless entry == :pre_late_input
          expect(body).not_to have_css('p[id=past_due_input]') if entry == :pre_late_input
          expect(body).to have_css('fieldset[id=past_due_fieldset]') unless entry == :pre_late_input
          expect(body).not_to have_css('fieldset[id=past_due_fieldset]') if entry == :pre_late_input

          expect(body).to have_css('p[id=coming_due_events_input]', text: ViewsHelpers::COMING_DUE_INITIAL_INPUT) unless entry == :pre_coming_due_input
          expect(body).not_to have_css('p[id=coming_due_events_input]') if entry == :pre_coming_due_input
          expect(body).to have_css('fieldset[id=coming_due_events_fieldset]') unless entry == :pre_coming_due_input
          expect(body).not_to have_css('fieldset[id=coming_due_events_fieldset]') if entry == :pre_coming_due_input

          expect(body).to have_css('p[id=completed_awaiting_events_input]', text: ViewsHelpers::COMPLETE_AWAITING_INITIAL_INPUT) unless entry == :completed_awaiting_input
          expect(body).not_to have_css('p[id=completed_awaiting_events_input]') if entry == :completed_awaiting_input
          expect(body).to have_css('fieldset[id=completed_awaiting_events_fieldset]') unless entry == :completed_awaiting_input
          expect(body).not_to have_css('fieldset[id=completed_awaiting_events_fieldset]') if entry == :completed_awaiting_input

          expect(body).to have_css('p[id=completed_events_input]', text: ViewsHelpers::COMPLETE_INITIAL_INPUT) unless entry == :completed_input
          expect(body).not_to have_css('p[id=completed_events_input]') if entry == :completed_input
          expect(body).to have_css('fieldset[id=completed_events_fieldset]') unless entry == :completed_input
          expect(body).not_to have_css('fieldset[id=completed_events_fieldset]') if entry == :completed_input

          expect(body).to have_css('p[id=closing_input]', text: ViewsHelpers::CLOSING_INITIAL_INPUT) unless entry == :closing_input
          expect(body).not_to have_css('p[id=closing_input]') if entry == :closing_input

          expect(body).to have_css('p[id=salutation_input]', text: ViewsHelpers::SALUTATION_INITIAL_INPUT) unless entry == :salutation_input
          expect(body).not_to have_css('p[id=salutation_input]') if entry == :salutation_input

          expect(body).to have_css('p[id=from_input]', text: I18n.t(ViewsHelpers::FROM_EMAIL_INPUT_I18N, name: @admin.contact_name, email: @admin.email, phone: @admin.contact_phone)) unless entry == :from_input
          expect(body).not_to have_css('p[id=from_input]', text: 'Vicki Kristoff test@example.com 919-249-5629 ') if entry == :from_input

          expect(send_grid_mail.attachments.empty?).to eq(true)
          # rubocop:enable Layout/LineLength
        end
      end
    end
  end

  private

  def expect_basic_admin_info(body, subject)
    expect(body).to have_css('p[id=admin-info]', text: 'Vicki Kristoff')
    expect(body).to have_css('p[id=admin-info]', text: I18n.t('views.top_bar.contact_admin_mail_text', email: @admin.email))
    expected_msg_one = I18n.t('views.top_bar.contact_admin_mail', email: @admin.email, subject: subject)
    expected_msg_two = I18n.t('views.top_bar.contact_admin_mail_text', email: @admin.email)
    expect(body).to have_css("a[id=admin-email][href='#{expected_msg_one}']", text: expected_msg_two)
    expect(body).to have_css('p[id=admin-info]', text: '919-249-5629')
  end

  def expect_basic_candidate_info(body, candidate)
    expect(body).to have_css('p[id=home-link]', text: I18n.t('email.website_name', home_parish: Visitor.home_parish))
    expected_msg = I18n.t('email.website_name', home_parish: Visitor.home_parish)
    expect(body).to have_css("p[id=home-link] a[href='http://localhost:3000/']", text: expected_msg)
    expect(body).to have_css('p[id=account-name]', text: candidate.account_name)
  end
end

# SendGridMailSpec
#
class SendGridMailSpec < SendGridMail
  # save_upload
  #
  # === Parameters:
  #
  # * <tt>:admin</tt>
  # * <tt>:candidates</tt>
  # * <tt>:options</tt>
  #
  # === Returns:
  #
  # * <tt>SendGridMailSpec</tt>
  #
  def initialize(admin, candidates, _options = {})
    super(admin, candidates)
  end

  # post_email
  #
  # === Parameters:
  #
  # * <tt>:sg_mail</tt>
  #
  # === Returns:
  #
  # * <tt>DummyGoodResponse</tt>
  #
  def post_email(sg_mail)
    @sg_mail = sg_mail
    DummyGoodResponse.new
  end

  # expanded_text
  #
  # === Returns:
  #
  # * <tt>String</tt>
  #
  def expanded_text
    @sg_mail.contents.first['value']
  end

  # attachments
  #
  # === Returns:
  #
  # * <tt>Array</tt>
  #
  def attachments
    @sg_mail.attachments
  end
end

#
# Dummy response
#
class DummyGoodResponse
  # initialize
  #
  # === Returns:
  #
  # * <tt>DummyGoodResponse</tt>
  #
  def initialize
    raise(RuntimteError, 'Not in test mode') unless Rails.env.test?
  end

  # status_code
  #
  # === Returns:
  #
  # * <tt>String</tt>
  #
  def status_code
    '202'
  end

  # body
  #
  # === Returns:
  #
  # * <tt>String</tt>
  #
  def body
    'testing response body'
  end
end
