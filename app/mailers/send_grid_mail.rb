# frozen_string_literal: true

require 'constants'

#
# Generates and sends email through SendGrid
#
# === Parameters:
#
# * <tt>:admin</tt> The admin logged in.  If sent then doing a test email (adhoc, monthly mass mailing)
# * <tt>:candidates</tt> Array of candidates who are being emailed
#
class SendGridMail
  include SendGrid

  # Instantiation
  #
  # === Parameters:
  #
  # * <tt>:admin</tt> from
  # * <tt>:candidates</tt> to
  #
  def initialize(admin, candidates)
    @admin = admin
    @candidates = candidates
    @email_index = -1
  end

  # legal emails for non-production
  #
  # === Returns:
  #
  # * <tt>Array</tt> of legal emails for non-production
  #
  def legal_emails
    %w[stmm.confirmation@kristoffs.com stmm.confirmationa@aol.com paul@kristoffs.com paul.kristoff@kristoffs.com retail@kristoffs.com justfaith@kristoffs.com financial@kristoffs.com]
  end

  # convert illegal email to one of these in non-production
  #
  # === Returns:
  #
  # * <tt>Array</tt> of legal emails for non-production
  #
  def convert_email
    %w[paul@kristoffs.com paul.kristoff@kristoffs.com retail@kristoffs.com justfaith@kristoffs.com financial@kristoffs.com]
  end

  # Generate and send adhoc email
  #
  # === Parameters:
  #
  # * <tt>:subject_mail_part</tt> The subject of the email put in by the admin
  # * <tt>:attach_file</tt> uploaded file to be attached to email.
  # * <tt>:body_mail_part</tt> The body of the email puy in by the admin
  #
  def adhoc(subject_mail_part, attach_file, body_mail_part)
    send_email(subject_mail_part,
               attach_file,
               body_mail_part,
               EmailStuff::TYPES[:adhoc],
               adhoc_call)
  end

  # Generate and send adhoc test email
  #
  # === Parameters:
  #
  # * <tt>:subject_mail_part</tt> The subject of the email put in by the admin
  # * <tt>:attach_file</tt> uploaded file to be attached to email.
  # * <tt>:body_mail_part</tt> The body of the email put in by the admin
  #
  def adhoc_test(subject_mail_part, attach_file, body_mail_part)
    send_email(subject_mail_part, attach_file, body_mail_part, EmailStuff::TYPES[:adhoc_test],
               adhoc_test_call,
               adhoc_test_subj_call)
  end

  # Generate and send candidate user id confirmation email
  #
  def confirmation_instructions
    [send_email(MailPart.new_subject(I18n.t('email.confirmation_instructions_subject')), nil, MailPart.new_body(''), EmailStuff::TYPES[:confirmation_instructions],
                conf_insts_call),
     @candidate_mailer_text.token]
  end

  # Generate and send monthly reminder email
  #
  # === Parameters:
  #
  # * <tt>:subject_mail_part</tt> The subject of the email put in by the admin
  # * <tt>:attach_file</tt> uploaded file to be attached to email.
  # * <tt>:body_input_mail_part</tt> The body of the email put in by the admin
  #
  def monthly_mass_mailing(subject_mail_part, attach_file, *body_input_mail_part)
    send_email(subject_mail_part, attach_file, *body_input_mail_part, EmailStuff::TYPES[:monthly_mass_mailing],
               mmm_call)
  end

  # Generate and send monthly reminder test email
  #
  # === Parameters:
  #
  # * <tt>:subject_mail_part</tt> The subject of the email put in by the admin
  # * <tt>:attach_file</tt> uploaded file to be attached to email.
  # * <tt>:body_input_mail_part</tt> The body of the email put in by the admin
  #
  def monthly_mass_mailing_test(subject_mail_part, attach_file, *body_input_mail_part)
    send_email(subject_mail_part, attach_file, *body_input_mail_part, EmailStuff::TYPES[:monthly_mass_mailing_test],
               mmm_test_call,
               mmm_test_subj_call)
  end

  # Generate and send reset password email
  #
  def reset_password
    [send_email(MailPart.new_subject(I18n.t('email.reset_password_subject')), nil, MailPart.new_body(''), EmailStuff::TYPES[:reset_password],
                reset_pass_call),
     @candidate_mailer_text.token]
  end

  # Generate and email.
  #
  # category is used to distinguish emails in SendGrid application
  #
  # === Parameters:
  #
  # * <tt>:subject_mail_part</tt> The subject of the email put in by the admin
  # * <tt>:email_type</tt> The type of email: adhoc, confirmation, etc.
  # * <tt>:account_name</tt> User id of candidate
  #
  # === Returns:
  #
  # * <tt>SendGrid::Email</tt>
  #
  def create_mail(subject_mail_part, email_type, account_name)
    mail = SendGrid::Mail.new
    # If we are testing don't actuallly send just have SendGrid validate it.
    if Rails.env.test?
      mail_settings = SendGrid::MailSettings.new
      mail_settings.sandbox_mode = SendGrid::SandBoxMode.new(enable: true)
      mail.mail_settings = mail_settings
    end
    mail.from = SendGrid::Email.new(email: 'stmm.confirmation@kristoffs.com', name: 'St MM Confirmation')
    mail.subject = subject_mail_part.text
    cat_env = ''
    cat_env = 'test' if Rails.env.test?
    cat_env = 'development' if Rails.env.development?
    cat_env = 'production' if Rails.env.production?
    mail.add_category(SendGrid::Category.new(name: cat_env))
    mail.add_category(SendGrid::Category.new(name: email_type))
    mail.add_category(SendGrid::Category.new(name: account_name))
    mail
  end

  # Create personalizations
  #
  # === Parameters:
  #
  # * <tt>:candidate</tt> The candidate.
  # * <tt>:sg_mail</tt> An instance of SendGrid::Email
  # * <tt>:admin</tt> The admin logged in.  If sent then doing a test email (adhoc, monthly mass mailing)
  # * <tt>:subs</tt> Any substitutions that SendGrid can do.  This is currently not being used.
  #
  def create_personalization(candidate, sg_mail, admin, *subs)
    personalization = SendGrid::Personalization.new
    if admin.nil? # unless test email
      sheet = candidate.candidate_sheet
      used = ['stmm.confirmation@kristoffs.com']
      converted_emails = convert_emails([sheet.to_email, sheet.cc_email, sheet.cc_email_2], used)
      personalization.add_to(SendGrid::Email.new(email: converted_emails[0], name: "#{sheet.first_name} #{sheet.last_name}"))
      personalization.add_cc(SendGrid::Email.new(email: converted_emails[1])) unless converted_emails[1].nil?
      personalization.add_cc(SendGrid::Email.new(email: converted_emails[2])) unless converted_emails[2].nil?
      personalization.add_bcc(SendGrid::Email.new(email: 'stmm.confirmation@kristoffs.com', name: 'St MM Confirmation'))
    else
      personalization.add_to(SendGrid::Email.new(email: admin.email, name: 'admin'))
    end
    subs.each { |sub| personalization.add_substitution(sub) }
    sg_mail.add_personalization(personalization)
    personalization
  end

  # In non-production(test development or pipeline=staging) will convert
  # illegal non-production email addresses to legal ones
  #
  # === Parameters:
  #
  # * <tt>:emails</tt> Array of email addresses. Can be nil or ''
  # * <tt>:used</tt> List of emai addresses alrady used for this email
  #
  # === Returns:
  #
  # * <tt>Array</tt> In production - Array of passed in email addresses. else - Array of legal non-production email addresses
  #
  def convert_emails(emails, used)
    legal_used = []
    emails.each do |em|
      legal_used << em if legal_emails.include? em
    end
    emails.map do |em|
      convert_if_not_production(em, used, legal_used)
    end
  end

  # In non-production(test development or pipeline=staging) will convert
  # illegal non-production email address to legal one
  #
  # === Parameters:
  #
  # * <tt>:email</tt> email address to be converted
  # * <tt>:used</tt>  Array of email addresses already used
  # * <tt>:legal_used</tt>  Array of legal email addresses.  If converted and in this array do not use.
  #
  # === Returns:
  #
  # * <tt>Array</tt> In production - email address passed in with '' converted to nil. else - email address if not legal.
  #
  def convert_if_not_production(email, used = [], legal_used = [])
    if email.blank?
      nil
    elsif Rails.application.secrets.pipeline == 'production'
      email
    elsif legal_emails.include?(email)
      email
    else
      @email_index += 1
      em = convert_email[@email_index]
      while (used.include? em) || (legal_used.include? em)
        @email_index += 1
        em = convert_email[@email_index]
      end
      em
    end
  end

  # Expand the email text making any necessary substitutions.
  #
  # === Parameters:
  #
  # * <tt>:candidate</tt> The candidate
  # * <tt>:subject_mail_part</tt> The subject of the email put in by the admin
  # * <tt>:body_input_mail_part</tt> The body of the email put in by the admin
  # * <tt>:delivery_call</tt> Generates and expands the email body
  #
  # === Returns:
  #
  # * <tt>Array</tt> In production - Array of passed in email addresses else - Array of legal non-production email addresses
  #
  def expand_text(candidate, subject_mail_part, body_input_mail_part, delivery_call)
    @candidate_mailer_text = CandidatesMailerText.new(candidate: candidate, subject: subject_mail_part, body_text: body_input_mail_part)

    delivery = delivery_call.call(@admin, @candidate_mailer_text)
    text(delivery)
  end

  # Send the attach_file to admin.
  #
  # === Parameters:
  #
  # * <tt>:attach_file_path</tt> The excel spread sheet
  #
  # === Returns:
  #
  # * <tt>Number</tt> response code from sending an email.
  #
  def export_to_excel_no_pictures_message(attach_file_path)
    send_email_admin(MailPart.new_subject('Export to excel NO scanned pictures'), 'Please see the attached excel spreadsheet.', attach_file_path)
  end

  # Send error message to admin.
  #
  # === Parameters:
  #
  # * <tt>:message</tt> error message
  # * <tt>:backtrace</tt> backtrace
  # * <tt>:attach_file_path</tt> nil - should not be used.
  #
  # === Returns:
  #
  # * <tt>Number</tt> response code from sending an email.
  #
  def email_error_message(message, backtrace, attach_file_path = nil)
    send_email_admin(MailPart.new_subject('Error in job'), "#{message} <br/> <br/> backtrace: #{backtrace}", attach_file_path)
  end

  # Send error message to admin.
  #
  # === Parameters:
  #
  # * <tt>:subject_mail_part</tt> email subject
  # * <tt>:body_mail_part</tt> email body
  # * <tt>:attach_file_path</tt> path to the file to attach
  #
  # === Returns:
  #
  # * <tt>Number</tt> response code from sending an email.
  #
  def send_email_admin(subject_mail_part, body_mail_part, attach_file_path)
    email_type = EmailStuff::TYPES[:email_error_message]
    sg_mail = create_mail(subject_mail_part, email_type, @admin.name)

    add_attachment_file_xlxs(File.new(attach_file_path), sg_mail, attach_file_path) unless attach_file_path.nil?

    create_personalization(nil, sg_mail, @admin)

    sg_mail.add_content(SendGrid::Content.new(type: 'text/html', value: body_mail_part))

    response = post_email(sg_mail)

    handle_bad_response(response, email_type, @admin.name)

    response
  end

  # Expand the email text making any necessary substitutions.
  #
  # === Parameters:
  #
  # * <tt>:attach_file_path</tt> The path to the excel spread sheet
  #
  # === Returns:
  #
  # * <tt>Number</tt> response code from sending an email.
  #
  def export_to_excel_pictures_message(attach_file_path)
    send_email_admin(MailPart.new_subject('Export to excel with scanned pictures'), MailPart.new_body('Please see the attached zip file.'), attach_file_path)
  end

  # Send the email to SendGrid, which will send the email
  #
  # === Parameters:
  #
  # * <tt>:sg_mail</tt> An instance of SendGrid::Email
  #
  # === Returns:
  #
  # * <tt>Response</tt> from SendGrid
  #
  def post_email(sg_mail)
    sg = SendGrid::API.new(api_key: Rails.application.secrets.email_key, host: 'https://api.sendgrid.com')
    begin
      response = sg.client.mail._('send').post(request_body: sg_mail.to_json)
    rescue SocketError
      if Rails.env.test?
        # not connected to the internet - so just allow it to continue.
        return Response.new(OfflineResponse.new)
      end
    end
    response
  end

  # Generates and sends the email
  #
  # === Parameters:
  #
  # * <tt>:subject_mail_part</tt> The subject of the email put in by the admin
  # * <tt>:attach_file</tt> a file to be uploaded and attached to the email.
  # * <tt>:body_mail_part</tt> The body of the email put in by the admin
  # * <tt>:email_type</tt> The type of email: adhoc, confirmation, etc.
  # * <tt>:delivery_call</tt> Generates and expands the email body
  # * <tt>:test_subject</tt> The subject of the email when it is a test email
  #
  # === Returns:
  #
  # * <tt>String</tt>
  #
  def send_email(subject_mail_part, attach_file, body_mail_part, email_type, delivery_call, test_subject = nil)
    last_failed_response = nil
    response = nil
    content = attach_file.read unless attach_file.nil?

    @candidates.each do |candidate|
      sg_mail = create_mail((test_subject.nil? ? subject_mail_part : MailPart.new_subject(test_subject.call(candidate))), email_type, candidate.account_name)

      add_attachment_file(attach_file, sg_mail, content) unless attach_file.nil?

      create_personalization(candidate, sg_mail, test_subject ? @admin : nil)

      expanded_text = expand_text(candidate, subject_mail_part, body_mail_part, delivery_call)

      sg_mail.add_content(SendGrid::Content.new(type: 'text/html', value: expanded_text))

      response = post_email(sg_mail)
      next if response.status_code[0].to_s == '2'

      last_failed_response = response
      Rails.logger.info("Bad response for #{email_type} message for #{candidate.account_name} because of a bad response: #{response.status_code}")
      Rails.logger.info("Status=#{response.status_code} body=#{response.body}")
    end
    last_failed_response || response
  end

  # Generates email body with expansion
  #
  # === Parameters:
  #
  # * <tt>:delivery</tt> SendGrid
  #
  # === Returns:
  #
  # * <tt>String</tt> The expanded email body
  #
  def text(delivery)
    message = delivery.message
    message.body.to_s
  end

  # TEST ONLY
  # expand text
  #
  # === Parameters:
  #
  # * <tt>:candidate</tt> Candidate
  #
  def expand_text_ci(candidate)
    expand_text(candidate, MailPart.new_subject('StMM website for Confirmation Candidates - User Verification instructions'), MailPart.new_body(''),
                conf_insts_call)
  end

  # TEST ONLY
  # expand text
  #
  # === Parameters:
  #
  # * <tt>:candidate</tt> Candidate
  #
  def expand_text_rp(candidate)
    expand_text(candidate, MailPart.new_subject("#{candidate.home_parish} website for Confirmation Candidates - Reset password instructions"), MailPart.new_body(''),
                reset_pass_call)
  end

  private

  def handle_bad_response(response, email_type, name)
    Rails.logger.info("Skipping sending #{email_type} message for #{name} because of a bad response") if response.status_code[0] != '2'
    Rails.logger.info("Status=#{response.status_code} body=#{response.body}") if response.status_code[0] != '2'
  end

  def add_attachment_file(attach_file, sg_mail, content)
    attachment = Attachment.new
    content64 = Base64.strict_encode64(content)
    attachment.content = content64
    attachment.type = attach_file.content_type
    attachment.filename = attach_file.original_filename
    attachment.disposition = 'attachment'
    sg_mail.add_attachment(attachment)
  end

  def add_attachment_file_xlxs(attach_file, sg_mail, path)
    attachment = Attachment.new
    content = attach_file.read
    content64 = Base64.strict_encode64(content)
    attachment.content = content64
    attachment.type = 'application/xlsx'
    attachment.filename = path
    attachment.disposition = 'attachment'
    sg_mail.add_attachment(attachment)
  end

  # def add_attachment_file_zip(attach_file, sg_mail, path)
  #   uploaded_file = attach_file
  #
  #   attachment = Attachment.new
  #   content = uploaded_file.read
  #   content64 = Base64.strict_encode64(content)
  #   attachment.content = content64
  #   attachment.type = 'application/zip'
  #   attachment.filename = path
  #   attachment.disposition = 'attachment'
  #   sg_mail.add_attachment(attachment)
  # end

  #
  # Generates email body for adhoc email
  #
  # === Parameters:
  #
  # === returns:
  #
  # A lambda
  #
  def adhoc_call
    ->(admin, candidate_mailer_text) { CandidatesMailer.adhoc(admin, candidate_mailer_text) }
  end

  #
  # Generates email body for adhoc test email
  #
  # === Parameters:
  #
  # === returns:
  #
  # A lambda
  #
  def adhoc_test_call
    ->(admin, candidate_mailer_text) { CandidatesMailer.adhoc_test(admin, candidate_mailer_text) }
  end

  #
  # Generates email body for adhoc test subject
  #
  # === Parameters:
  #
  #
  # === returns:
  #
  # A lambda
  #
  def adhoc_test_subj_call
    ->(candidate) { I18n.t('email.test_adhoc_subject_initial_input', candidate_account_name: candidate.account_name) }
  end

  #
  # Generates email body for confirmation email
  #
  # === Parameters:
  #
  # === returns:
  #
  # A lambda
  #
  def conf_insts_call
    ->(_admin, candidate_mailer_text) { candidate_mailer_text.candidate.confirmation_instructions(candidate_mailer_text) }
  end

  #
  # Generates email body for monthly mass mailing
  #
  # === Parameters:
  #
  # === returns:
  #
  # A lambda
  #
  def mmm_call
    ->(admin, candidate_mailer_text) { CandidatesMailer.monthly_reminder(admin, candidate_mailer_text) }
  end

  #
  # Generates email body for monthly mass test mailing
  #
  # === Parameters:
  #
  # === returns:
  #
  # A lambda
  #
  def mmm_test_call
    ->(admin, candidate_mailer_text) { CandidatesMailer.monthly_reminder_test(admin, candidate_mailer_text) }
  end

  #
  # Generates email body for monthly mass mailing test subject
  #
  # === Parameters:
  #
  # === returns:
  #
  # A lambda
  #
  def mmm_test_subj_call
    ->(candidate) { I18n.t('email.test_monthly_mail_subject_initial_input', candidate_account_name: candidate.account_name) }
  end

  def reset_pass_call
    ->(_admin, candidate_mailer_text) { candidate_mailer_text.candidate.password_reset_message(candidate_mailer_text) }
  end
end

#
# An exception used when running tests and you are not connected to the internet.
#
class OfflineResponse
  def initialize
    raise(RuntimteError, 'Not in test mode') unless Rails.env.test?
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
