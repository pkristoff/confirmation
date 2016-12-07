class CandidatesMailer < ActionMailer::Base

  default from: 'vicki@kristoffs.com'
  default reply_to: 'stmm.confirmation@kristoffs.com'

  def monthly_reminder(candidate, subject, pre_late_text, pre_coming_due_text, completed_text, closing_text, salutation_text, from_text)
    @candidate = candidate
    @pre_late_text = pre_late_text
    @pre_coming_due_text = pre_coming_due_text
    @completed_text = completed_text
    @closing_text = closing_text
    @salutation_text = salutation_text
    @from_text = from_text
    #matches AdminsController#setup_email_candidate
    @late_events = candidate.get_late_events
    @coming_due_events = candidate.get_coming_due_events
    @completed_events = candidate.get_completed

    mail(
        to: "#{candidate.candidate_sheet.candidate_email}, #{candidate.candidate_sheet.parent_email_1}, #{candidate.candidate_sheet.parent_email_2}",
        subject: subject
    ) do |format|
      format.html
    end

  end

end