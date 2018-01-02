include ViewsHelpers

describe SendGridMail, type: :model do

  describe 'monthly_reminder testing' do

    before(:each) do
      @admin = FactoryBot.create(:admin)
      candidate = create_candidate('Paul', 'Richard', 'Kristoff')
      AppFactory.add_confirmation_events
      @candidate = Candidate.find_by_account_name(candidate.account_name)
    end

    it 'should expand the adhoc email for candidate' do
      send_grid_mail = SendGridMail.new(@admin, [@candidate])
      text = send_grid_mail.expand_text_adhoc(@candidate, SUBJECT, body_input: COMPLETE_AWAITING_INITIAL_TEXT)

      body = Capybara.string(text)
      expect(body).to have_css('p[id=first_name]', text: @candidate.candidate_sheet.first_name)
      expect(body).to have_css('p[id=body_text]', text: COMPLETE_AWAITING_INITIAL_TEXT)
    end

    it 'should expand the adhoc test email for candidate' do
      send_grid_mail = SendGridMail.new(@admin, [@candidate])
      text = send_grid_mail.expand_text_at(@candidate, SUBJECT, body_input: CLOSING_INITIAL_TEXT)

      body = Capybara.string(text)
      expect(body).to have_css('li[id=candidate-email]', text: @candidate.candidate_sheet.candidate_email)
      expect(body).to have_css('li[id=parent-email-1]', text: @candidate.candidate_sheet.parent_email_1)
      expect(body).to have_css('li[id=parent-email-2]', text: @candidate.candidate_sheet.parent_email_2)
      expect(body).to have_css('p[id=subject]', text: SUBJECT)

      expect(body).to have_css('p[id=first_name]', text: @candidate.candidate_sheet.first_name)
      expect(body).to have_css('p[id=body_text]', text: CLOSING_INITIAL_TEXT)
    end

    it 'should expand the account confirmation instructions for candidate' do
      send_grid_mail = SendGridMail.new(@admin, [@candidate])
      text = send_grid_mail.expand_text_ci(@candidate)

      body = Capybara.string(text)
      expect(body).to have_css('p[id=welcome]', text: "Welcome #{@candidate.candidate_sheet.first_name}  #{@candidate.candidate_sheet.last_name}")
      expect_basic_candidate_info(body, @candidate)
      expect_basic_admin_info(body, 'Account%20confirmation%20instructions')
    end

    it 'should expand the monthly reminder email for candidate' do
      send_grid_mail = SendGridMail.new(@admin, [@candidate])
      text = send_grid_mail.expand_text_mmm(@candidate, SUBJECT, pre_late_text: LATE_INITIAL_TEXT,
                                            pre_coming_due_text: COMING_DUE_INITIAL_TEXT,
                                            completed_awaiting_text: COMPLETE_AWAITING_INITIAL_TEXT,
                                            completed_text: COMPLETE_INITIAL_TEXT, closing_text: CLOSING_INITIAL_TEXT,
                                            salutation_text: SALUTATION_INITIAL_TEXT, from_text: FROM_EMAIL_TEXT)

      body = Capybara.string(text)
      expect(body).to have_css('p[id=past_due_text]', text: LATE_INITIAL_TEXT)
      expect(body).to have_css('p[id=coming_due_events_text]', text: COMING_DUE_INITIAL_TEXT)
      expect(body).to have_css('p[id=completed_awaiting_events_text]', text: COMPLETE_AWAITING_INITIAL_TEXT)
      expect(body).to have_css('p[id=closing_text]', text: CLOSING_INITIAL_TEXT)
      expect(body).to have_css('p[id=completed_events_text]', text: COMPLETE_INITIAL_TEXT)
      expect(body).to have_css('p[id=salutation_text]', text: SALUTATION_INITIAL_TEXT)
      expect(body).to have_css('p[id=from_text]', text: FROM_EMAIL_TEXT)
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
      @candidate = Candidate.find_by_account_name(candidate.account_name)
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
        expect(send_grid_mail.convert_emails(%w(prk1@test.com prk2@test.com), ['stmm.confirmation@kristoffs.com'])).to eq(%w(paul@kristoffs.com paul.kristoff@kristoffs.com))
      end

      it 'should return local email when multiple emails and one local when PIPELINE=nil' do
        Rails.application.secrets.pipeline = nil
        send_grid_mail = SendGridMail.new(@admin, [@candidate])
        expect(send_grid_mail.convert_if_not_production('paul@kristoffs.com', [], ['paul@kristoffs.com'])).to eq('paul@kristoffs.com')
        expect(send_grid_mail.convert_if_not_production('prk2@test.com', ['paul@kristoffs.com'], ['paul@kristoffs.com'])).to eq('paul.kristoff@kristoffs.com')
      end
      it 'should return local email when multiple emails and one local when PIPELINE=nil for convert_emails' do
        Rails.application.secrets.pipeline = nil
        send_grid_mail = SendGridMail.new(@admin, [@candidate])
        expect(send_grid_mail.convert_emails(%w(paul@kristoffs.com prk2@test.com), ['stmm.confirmation@kristoffs.com'])).to eq(%w(paul@kristoffs.com paul.kristoff@kristoffs.com))
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
        expect(send_grid_mail.convert_emails(%w(paul.kristoff@kristoffs.com prk2@test.com), ['stmm.confirmation@kristoffs.com'])).to eq(%w(paul.kristoff@kristoffs.com paul@kristoffs.com))
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
        expect(send_grid_mail.convert_emails(%w(paul@kristoffs.com prk2@test.com), ['stmm.confirmation@kristoffs.com'])).to eq(%w(paul@kristoffs.com paul.kristoff@kristoffs.com))
      end

      it 'should return local email when multiple emails when PIPELINE=staging' do
        Rails.application.secrets.pipeline = 'staging'
        send_grid_mail = SendGridMail.new(@admin, [@candidate])
        expect(send_grid_mail.convert_if_not_production('camping@kristoffs.com', [], ['paul@kristoffs.com'])).to eq('paul.kristoff@kristoffs.com')
        expect(send_grid_mail.convert_if_not_production('paul@kristoffs.com', ['paul.kristoff@kristoffs.com'], ['paul@kristoffs.com'])).to eq('paul@kristoffs.com')
        expect(send_grid_mail.convert_if_not_production('medical@kristoffs.com', ['paul.kristoff@kristoffs.com', 'paul@kristoffs.com'], ['paul@kristoffs.com'])).to eq('retail@kristoffs.com')
      end
      it 'should return local email when multiple emails when PIPELINE=staging' do
        Rails.application.secrets.pipeline = 'staging'
        send_grid_mail = SendGridMail.new(@admin, [@candidate])
        expect(send_grid_mail.convert_emails(%w(camping@kristoffs.com paul@kristoffs.com medical@kristoffs.com), ['stmm.confirmation@kristoffs.com'])).to eq(%w(paul.kristoff@kristoffs.com paul@kristoffs.com retail@kristoffs.com))
      end

      it 'should return local email when multiple emails when PIPELINE=staging' do
        Rails.application.secrets.pipeline = 'staging'
        send_grid_mail = SendGridMail.new(@admin, [@candidate])
        expect(send_grid_mail.convert_if_not_production('prk1@test.com')).to eq('paul@kristoffs.com')
        expect(send_grid_mail.convert_if_not_production('retail@kristoffs.com', ['paul@kristoffs.com'])).to eq('retail@kristoffs.com')
        expect(send_grid_mail.convert_if_not_production('prk2@test.com', ['paul@kristoffs.com', 'retail@kristoffs.com'])).to eq('paul.kristoff@kristoffs.com')
        expect(send_grid_mail.convert_if_not_production('prk3@test.com', ['paul@kristoffs.com', 'retail@kristoffs.com', 'paul.kristoff@kristoffs.com'])).to eq('justfaith@kristoffs.com')
      end
      it 'should return local email when multiple emails when PIPELINE=staging for convert_emails' do
        Rails.application.secrets.pipeline = 'staging'
        send_grid_mail = SendGridMail.new(@admin, [@candidate])
        expect(send_grid_mail.convert_emails(%w(prk1@test.com retail@kristoffs.com prk2@test.com prk3@test.com), ['stmm.confirmation@kristoffs.com'])).to eq(%w(paul@kristoffs.com retail@kristoffs.com paul.kristoff@kristoffs.com justfaith@kristoffs.com))
      end

      it 'should return unchanged email when PIPELINE=production' do
        Rails.application.secrets.pipeline = 'production'
        send_grid_mail = SendGridMail.new(@admin, [@candidate])
        expect(send_grid_mail.convert_if_not_production('prk@test.com')).to eq('prk@test.com')
      end
      it 'should return unchanged email when PIPELINE=production for convert_emails' do
        Rails.application.secrets.pipeline = 'production'
        send_grid_mail = SendGridMail.new(@admin, [@candidate])
        expect(send_grid_mail.convert_emails(%w(prk@test.com), ['stmm.confirmation@kristoffs.com'])).to eq(%w(prk@test.com))
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
        expect(send_grid_mail.convert_emails(%w(prk1@test.com retail@test.com), ['stmm.confirmation@kristoffs.com'])).to eq(%w(prk1@test.com retail@test.com))
      end
    end
  end


  def expect_basic_admin_info(body, subject)
    expect(body).to have_css('p[id=admin-info]', text: 'Vicki Kristoff')
    expect(body).to have_css('p[id=admin-info]', text: I18n.t('views.top_bar.contact_admin_mail_text'))
    expect(body).to have_css("a[id=admin-email][href='#{I18n.t('views.top_bar.contact_admin_mail', subject: subject)}']", text: I18n.t('views.top_bar.contact_admin_mail_text'))
    expect(body).to have_css("p[id=admin-info]", text: I18n.t('views.top_bar.contact_admin_phone'))
  end

  def expect_basic_candidate_info(body, candidate)
    expect(body).to have_css('p[id=home-link]', text: I18n.t('email.website_name'))
    expect(body).to have_css("p[id=home-link] a[href='http://localhost:3000/']", text: I18n.t('email.website_name'))
    expect(body).to have_css("p[id=account-name]", text: candidate.account_name)
  end

end