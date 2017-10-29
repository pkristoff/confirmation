class SendGridMail

  def initialize(admin, candidates)
    @admin = admin
    @candidates = candidates
  end

  def adhoc(subject_text, body_input_text)

    send_email(subject_text, body_input_text, 'adhoc',
               adhoc_call
    )
  end

  def adhoc_test(subject_text, body_input_text)
    send_email(subject_text, body_input_text, 'adhoc_test',
               adhoc_test_call,
               adhoc_test_subj_call
    )
  end

  def confirmation_instructions(subject_text, body_input_text)
    send_email(I18n.t('email.confirmation_instructions_subject'), '', 'confirmation_instructions',
               conf_insts_call
    )
  end

  def monthly_mass_mailing(subject_text, *body_input_text)

    send_email(subject_text, *body_input_text, 'monthly_mass_mailing',
               mmm_call
    )
  end

  def monthly_mass_mailing_test(subject_text, *body_input_text)

    send_email(subject_text, *body_input_text, 'monthly_mass_mailing_test',
               mmm_test_call,
               mmm_test_subj_call
    )
  end

  def reset_password
    send_email(I18n.t('email.reset_password_subject'), '', 'reset_password',
               reset_pass_call
    )
  end


  def create_mail(subject, email_type, account_name)
    mail = SendGrid::Mail.new
    if Rails.env.test?
      mail_settings = SendGrid::MailSettings.new
      mail_settings.sandbox_mode = SandBoxMode.new(enable: true)
      mail.mail_settings = mail_settings
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

  def expand_text(candidate, subject_text, body_input_text, delivery_call)
    @candidate_mailer_text = CandidatesMailerText.new(candidate: candidate, subject: (subject_text), body_input: body_input_text)

    delivery = delivery_call.call(@admin, @candidate_mailer_text)
    text(delivery)
  end

  def post_email(sg_mail)
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

  def send_email(subject_text, body_input_text, email_type, delivery_call, test_subject=nil)

    response = nil

    @candidates.each_with_index do |candidate, index|

      sg_mail = create_mail((test_subject.nil? ? subject_text : test_subject.call(candidate)), email_type, candidate.account_name)

      create_personalization(candidate, sg_mail, test_subject ? @admin : nil)

      expanded_text = expand_text(candidate, subject_text, body_input_text, delivery_call)

      sg_mail.add_content(SendGrid::Content.new(type: 'text/html', value: expanded_text))

      response = post_email(sg_mail)

      if response.status_code[0] != '2'
        Rails.logger.info("Skipping sending #{email_type} message for #{candidate.account_name} because of a bad response")
        Rails.logger.info("Status=#{response.status_code} body=#{response.body}")
      end
    end
    response
  end

  def text(delivery)
    message = delivery.message
    text = message.body.to_s
    # puts "text=#{text}"
  end

  def adhoc_call
    lambda {|admin, candidate_mailer_text| CandidatesMailer.adhoc(admin, candidate_mailer_text)}
  end

  def adhoc_test_call
    lambda {|admin, candidate_mailer_text| CandidatesMailer.adhoc_test(admin, candidate_mailer_text)}
  end

  def adhoc_test_subj_call
    lambda {|candidate| I18n.t('email.test_adhoc_subject_initial_text', candidate_account_name: candidate.account_name)}
  end

  def conf_insts_call
    lambda {|admin, candidate_mailer_text| candidate_mailer_text.candidate.confirmation_instructions}
  end

  def mmm_call
    lambda {|admin, candidate_mailer_text| CandidatesMailer.monthly_reminder(admin, candidate_mailer_text)}
  end

  def mmm_test_call
    lambda {|admin, candidate_mailer_text| CandidatesMailer.monthly_reminder_test(admin, candidate_mailer_text)}
  end

  def mmm_test_subj_call
    lambda {|candidate| I18n.t('email.test_monthly_mail_subject_initial_text', candidate_account_name: candidate.account_name)}
  end

  def reset_pass_call
    lambda {|admin, candidate_mailer_text| candidate_mailer_text.candidate.password_reset_message}
  end

# TEST ONLY
  def expand_text_adhoc(candidate, subject_text, *body_input_text)

    expand_text(candidate, subject_text, *body_input_text,
                adhoc_call
    )
  end

# TEST ONLY
  def expand_text_at(candidate, subject_text, body_input_text)
    expand_text(candidate, subject_text, body_input_text,
                adhoc_test_call
    )
  end

# TEST ONLY
  def expand_text_ci(candidate)
    expand_text(candidate, 'StMM website for Confirmation Candidates - User Verification instructions', '',
                conf_insts_call
    )
  end

# TEST ONLY
  def expand_text_rp(candidate)
    expand_text(candidate, 'StMM website for Confirmation Candidates - Reset password instructions', '',
                reset_pass_call
    )
  end

# TEST ONLY
  def expand_text_mmm(candidate, subject_text, *body_input_text)
    expand_text(candidate, subject_text, *body_input_text,
                mmm_call
    )
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