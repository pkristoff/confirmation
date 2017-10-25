class SendGridMail

  def initialize(admin, candidates)
    @admin = admin
    @candidates = candidates
  end

  def adhoc(subject_text, body_input_text)

    send_email(subject_text, body_input_text, 'adhoc',
               lambda {| admin, candidate_mailer_text | CandidatesMailer.adhoc(admin, candidate_mailer_text)}
    )
  end

  def send_email(subject_text, body_input_text, email_type, delivery_call, test_subject=nil)

    response = nil

    @candidates.each_with_index do |candidate, index|

      sg_mail = create_mail((test_subject.nil? ? subject_text : test_subject.call(candidate)), email_type, candidate.account_name)

      @candidate_mailer_text = CandidatesMailerText.new(candidate: candidate, subject: (test_subject.nil? ? subject_text : test_subject.call(candidate)), body_input: body_input_text)

      create_personalization(candidate, sg_mail,test_subject ? @admin : nil)

      delivery = delivery_call.call(@admin, @candidate_mailer_text)
      set_text(delivery, sg_mail)
      response = post_email(sg_mail)
      if response.status_code[0] != '2'
        Rails.logger.info("Skipping sending #{email_type} message for #{candidate.account_name} because of a bad response")
        Rails.logger.info("Status=#{response.status_code} body=#{response.body}")
      end
    end
    response
  end

  def adhoc_test(subject_text, body_input_text)
    send_email(subject_text, body_input_text, 'adhoc_test',
               lambda {| admin, candidate_mailer_text | CandidatesMailer.adhoc_test(admin, candidate_mailer_text)},
               lambda {|candidate | I18n.t('email.test_adhoc_subject_initial_text', candidate_account_name: candidate.account_name)}
    )
  end

  def reset_password
    send_email('StMM website for Confirmation Candidates - Reset password instructions', '', 'reset_password',
               lambda {| admin, candidate_mailer_text | candidate_mailer_text.candidate.password_reset_message}
    )
  end


  def create_mail(subject, email_type, account_name)
    mail = SendGrid::Mail.new
    if Rails.env.test?
      mail_settings = SendGrid::MailSettings.new
      mail_settings.sandbox_mode = SandBoxMode.new(enable: true)
    end
    mail.from = SendGrid::Email.new(email: 'stmm.confirmation@kristoffs.com', name: 'St MM Confirmation')
    mail.subject = subject
    cat_env = ''
    cat_env = 'test' if Rails.env.test?
    cat_env = 'development' if Rails.env.development?
    cat_env = 'production' if Rails.env.production?
    mail.add_category(SendGrid::Category.new(name: cat_env))
    mail.add_category(SendGrid::Category.new(name: email_type))
    mail.add_category(SendGrid::Category.new(name: account_name))
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