# frozen_string_literal: true

#
# Used to send(expand) emails
#
class CandidatesMailer < ActionMailer::Base
  default from: 'stmm.confirmation@kristoffs.com'
  default reply_to: 'stmm.confirmation@kristoffs.com'

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
  # String:  expanded body text
  #
  def adhoc(_admin, candidate_mailer_text)
    setup_message_info(candidate_mailer_text)

    mail(
      to: "#{candidate_mailer_text.candidate.candidate_sheet.candidate_email}, #{candidate_mailer_text.candidate.candidate_sheet.parent_email_1}, #{candidate_mailer_text.candidate.candidate_sheet.parent_email_2}",
      subject: candidate_mailer_text.subject
    ) do |format|
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
  # String:  expanded body text
  #
  def adhoc_test(admin, candidate_mailer_text)
    setup_message_info(candidate_mailer_text)

    @subject = candidate_mailer_text.subject

    mail(to: admin.email.to_s,
         subject: I18n.t('email.test_adhoc_subject_initial_text', candidate_account_name: candidate_mailer_text.candidate.account_name)) do |format|
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
  # String:  expanded body text
  #
  def monthly_reminder(_admin, candidate_mailer_text)
    setup_message_info(candidate_mailer_text)

    mail(
      to: "#{candidate_mailer_text.candidate.candidate_sheet.candidate_email}, #{candidate_mailer_text.candidate.candidate_sheet.parent_email_1}, #{candidate_mailer_text.candidate.candidate_sheet.parent_email_2}",
      subject: candidate_mailer_text.subject
    ) do |format|
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
  # String:  expanded body text
  #
  def monthly_reminder_test(admin, candidate_mailer_text)
    setup_message_info(candidate_mailer_text)

    @subject = candidate_mailer_text.subject

    mail(to: admin.email.to_s,
         subject: I18n.t('email.test_monthly_mail_subject_initial_text', candidate_account_name: candidate_mailer_text.candidate.account_name)) do |format|
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
