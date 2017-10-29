include ViewsHelpers

describe SendGridMail, type: :model do

  describe 'monthly_reminder testing' do

    before(:each) do
      @admin = FactoryGirl.create(:admin)
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