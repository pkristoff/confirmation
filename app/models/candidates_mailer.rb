class CandidatesMailer < ActionMailer::Base

  default from: 'vicki@kristoffs.com'
  default reply_to: 'stmm.confirmation@kristoffs.com'

  def monthly_reminder(admin, candidateMailerText)
    setup_message_info(candidateMailerText)

    mail(
        to: "#{candidateMailerText.candidate.candidate_sheet.candidate_email}, #{candidateMailerText.candidate.candidate_sheet.parent_email_1}, #{candidateMailerText.candidate.candidate_sheet.parent_email_2}",
        subject: candidateMailerText.subject
    ) do |format|
      format.html
    end

  end

  def monthly_reminder_test(admin, candidate_mailer_text)
    setup_message_info(candidate_mailer_text)

    @subject = candidate_mailer_text.subject

    mail(to: admin.email.to_s,
         subject: I18n.t('email.test_mail_subject_initial_text', candidate_account_name: candidate_mailer_text.candidate.account_name)
    ) do |format|
      format.html
    end

  end

  def setup_message_info(candidate_mailer_text)
    @candidate_mailer_text = candidate_mailer_text
  end

end