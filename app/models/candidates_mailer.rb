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
    @candidate = candidate_mailer_text.candidate
    @pre_late_text = candidate_mailer_text.pre_late_text
    @pre_coming_due_text = candidate_mailer_text.pre_coming_due_text
    @completed_text = candidate_mailer_text.completed_text
    @closing_text = candidate_mailer_text.closing_text
    @salutation_text = candidate_mailer_text.salutation_text
    @from_text = candidate_mailer_text.from_text
    #matches AdminsController#setup_email_candidate
    @late_events = candidate_mailer_text.get_late_events
    @coming_due_events = candidate_mailer_text.get_coming_due_events
    @completed_events = candidate_mailer_text.get_completed
  end

end