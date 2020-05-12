# frozen_string_literal: true

#
# required subclass
#
class ApplicationMailer < ActionMailer::Base
end

#
# Used to send(expand) emails
#
class CandidatesMailer < ApplicationMailer
  # these should always be overriden since the Admin has the
  # contact info.
  default from: 'default.confirmation@kristoffs.com'
  default reply_to: 'default.confirmation@kristoffs.com'

  # generate email body for adhoc message - basically a free format
  # email.
  #
  # === Parameters:
  #
  # * <tt>:admin</tt> Admin: not used
  # * <tt>:candidate_mailer_text</tt> CandidateMailerText
  #
  # === Returns:
  #
  # * <tt>String</tt> expanded body text
  #
  def adhoc(admin, candidate_mailer_text)
    setup_message_info(candidate_mailer_text)
    candidate_email = candidate_mailer_text.candidate.candidate_sheet.candidate_email
    parent_email_one = candidate_mailer_text.candidate.candidate_sheet.parent_email_1
    parent_email_two = candidate_mailer_text.candidate.candidate_sheet.parent_email_2
    mail(to: "#{candidate_email}, #{parent_email_one}, #{parent_email_two}",
         subject: candidate_mailer_text.subject.text,
         from: admin.email,
         reply_to: admin.email) do |format|
      format.html
    end
  end

  # generate email body for adhoc message - send email to admin.
  # showing body, email addresses & subject
  #
  # === Parameters:
  #
  # * <tt>:admin</tt> Admin: indicates a test email
  # * <tt>:candidate_mailer_text</tt> CandidateMailerText
  #
  # === Returns:
  #
  # * <tt>String</tt> expanded body text
  #
  def adhoc_test(admin, candidate_mailer_text)
    setup_message_info(candidate_mailer_text)

    @subject = candidate_mailer_text.subject.text

    mail(to: admin.email.to_s,
         subject: I18n.t('email.test_adhoc_subject_initial_input',
                         candidate_account_name: candidate_mailer_text.candidate.account_name),
         from: admin.email,
         reply_to: admin.email) do |format|
      format.html
    end
  end

  # generate email body for reminder message -
  # indicating what candidate events are completed, late, & not late
  #
  # === Parameters:
  #
  # * <tt>:admin</tt> Admin: indicates whether a test message or not
  # * <tt>:candidate_mailer_text</tt> CandidateMailerText
  #
  # === Returns:
  #
  # * <tt>String</tt> expanded body text
  #
  def monthly_reminder(admin, candidate_mailer_text)
    setup_message_info(candidate_mailer_text)

    candidate_email = candidate_mailer_text.candidate.candidate_sheet.candidate_email
    parentemail1 = candidate_mailer_text.candidate.candidate_sheet.parent_email_1
    parentemail2 = candidate_mailer_text.candidate.candidate_sheet.parent_email_2
    mail(to: "#{candidate_email}, #{parentemail1}, #{parentemail2}",
         subject: candidate_mailer_text.subject.text,
         from: admin.email,
         reply_to: admin.email) do |format|
      format.html
    end
  end

  # generate email body for reminder message - sent to admin
  # indicating what candidate events are completed, late, & not latesend email to admin.
  # email addresses & subject
  #
  # === Parameters:
  #
  # * <tt>:admin</tt> Admin: indicates whether a test message or not
  # * <tt>:candidate_mailer_text</tt> CandidateMailerText
  #
  # === Returns:
  #
  # * <tt>String</tt> expanded body text
  #
  def monthly_reminder_test(admin, candidate_mailer_text)
    setup_message_info(candidate_mailer_text)

    @subject = candidate_mailer_text.subject.text

    mail(to: admin.email.to_s,
         subject: I18n.t('email.test_monthly_mail_subject_initial_input',
                         candidate_account_name: candidate_mailer_text.candidate.account_name),
         from: admin.email,
         reply_to: admin.email) do |format|
      format.html
    end
  end

  # Set @candidate_mailer_text
  #
  # === Parameters:
  #
  # * <tt>:candidate_mailer_text</tt> CandidateMailerText
  #
  def setup_message_info(candidate_mailer_text)
    @candidate_mailer_text = candidate_mailer_text
  end
end
