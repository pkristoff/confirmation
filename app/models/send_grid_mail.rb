class SendGridMail

  def initialize(admin, candidates)
    @admin = admin
    @candidates = candidates
  end

  def adhoc(subject_text, body_input_text)

    response = nil

    @candidates.each_with_index do |candidate, index|

      sg_mail = create_mail(subject_text)

      @candidate_mailer_text = CandidatesMailerText.new(candidate: candidate, subject: subject_text, body_input: body_input_text)

      create_personalization(candidate, sg_mail, nil,
                             SendGrid::Substitution.new(key: '%name%', value: candidate.candidate_sheet.first_name),
                             SendGrid::Substitution.new(key: '%body%', value: @candidate_mailer_text.body_text))

      delivery = CandidatesMailer.adhoc(@admin, @candidate_mailer_text)
      set_text(delivery, sg_mail)
      # puts "posting email"
      response = post_email(sg_mail)
      if response.status_code[0] != '2'
        Rails.logger.info("Skipping sending adhoc message for #{candidate.account_name} because of a bad response")
        Rails.logger.info("Status=#{response.status_code} body=#{response.body}")
      end
    end
    response
  end

  def adhoc_test(subject_text, body_input_text)
    sg_mail = create_mail(I18n.t('email.test_adhoc_subject_initial_text'))

    @candidates.each_with_index do |candidate, index|

      @candidate_mailer_text = CandidatesMailerText.new(candidate: candidate, subject: I18n.t('email.test_adhoc_subject_initial_text'), body_input: body_input_text)

      create_personalization(candidate, sg_mail, @admin,
                             SendGrid::Substitution.new(key: '%candidate_email%', value: candidate.candidate_sheet.candidate_email),
                             SendGrid::Substitution.new(key: '%parent_email_1%', value: candidate.candidate_sheet.parent_email_1),
                             SendGrid::Substitution.new(key: '%parent_email_2%', value: candidate.candidate_sheet.parent_email_2),
                             SendGrid::Substitution.new(key: '%subject_text%', value: subject_text),
                             SendGrid::Substitution.new(key: '%candidate_account_name%', value: @candidate_mailer_text.candidate.account_name),
                             SendGrid::Substitution.new(key: '%name%', value: candidate.candidate_sheet.first_name),
                             SendGrid::Substitution.new(key: '%body%', value: @candidate_mailer_text.body_text))
    end
    delivery = CandidatesMailer.adhoc_test(@admin, @candidate_mailer_text)
    set_text(delivery, sg_mail)
    # puts "posting email"
    post_email(sg_mail)
  end

  def reset_password
    response = nil
    @candidates.each_with_index do |candidate, index|
      Rails.logger.info("reset_password processing #{candidate.account_name}")
      if response.nil? || response.status_code[0] === '2'
        # Normally this would be send with one email and multiple personalizations but each message
        # has a unique token for a particular candidate and thus needs to be sent per candidate.
        sg_mail = create_mail('StMM website for Confirmation Candidates - Reset password instructions')
        @candidate_mailer_text = CandidatesMailerText.new(candidate: candidate, subject: I18n.t('email.test_adhoc_subject_initial_text'), body_input: '')

        create_personalization(candidate, sg_mail, nil)

        delivery = candidate.password_reset_message
        set_text(delivery, sg_mail)
        response = post_email(sg_mail)
        if response.status_code[0] != '2'
          Rails.logger.info("Skipping sending reset_password message for #{candidate.account_name} because of a bad response")
          Rails.logger.info("Status=#{response.status_code} body=#{response.body}")
        end
      end
    end
    response
  end


  def create_mail(subject)
    mail = SendGrid::Mail.new
    if Rails.env.test?
      mail_settings = SendGrid::MailSettings.new
      mail_settings.sandbox_mode = SandBoxMode.new(enable: true)
    end
    mail.from = SendGrid::Email.new(email: 'stmm.confirmation@kristoffs.com', name: 'St MM Confirmation')
    mail.subject = subject
    mail
  end

  def create_personalization(candidate, sg_mail, admin, *subs)
    personalization = SendGrid::Personalization.new
    sheet = candidate.candidate_sheet
    if admin.nil?
      personalization.add_to(SendGrid::Email.new(email: sheet.to_email, name: "#{sheet.first_name} #{sheet.last_name}"))
      personalization.add_cc(SendGrid::Email.new(email: sheet.cc_email)) unless sheet.cc_email.nil? || sheet.cc_email.empty?
      personalization.add_cc(SendGrid::Email.new(email: sheet.cc_email_2)) unless sheet.cc_email_2.nil? || sheet.cc_email_2.empty?
      personalization.add_bcc(SendGrid::Email.new(email: 'stmm.confirmation@kristoffs.com', name: 'St MM Confirmation'))
    else
      personalization.add_to(SendGrid::Email.new(email: admin.email, name: 'admin'))
    end
    subs.each {|sub| personalization.add_substitution(sub)}
    sg_mail.add_personalization(personalization)
    personalization
  end

  def post_email(sg_mail)
    sg_mail
    sg = SendGrid::API.new(api_key: Rails.application.secrets.email_key, host: 'https://api.sendgrid.com')
    begin
      response = sg.client.mail._('send').post(request_body: sg_mail.to_json)
    rescue SocketError
      if Rails.env.test?
        # not connected to the internet
        return Response.new(OfflineResponse.new)
      end
    end
    response
  end

  def set_text(delivery, sg_mail)
    message = delivery.message
    text = message.body.to_s
    # puts "text=#{text}"
    sg_mail.add_content(SendGrid::Content.new(type: 'text/html', value: text))
  end
end

class OfflineResponse
  def initialize
    unless Rails.env.test?
      raise RuntimteError.new('Not in test mode')
    end
  end
  def code
    '202'
  end
  def body
    ''
  end
  def to_hash
    {}
  end
end