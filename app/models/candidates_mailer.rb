class CandidatesMailer < ActionMailer::Base

  default from: 'confirmation@kristoffs.com'
  default reply_to: 'confirmation@kristoffs.com'

  def monthly_reminder(candidate, pre_late_text, pre_coming_due_text, completed_text)
    @candidate = candidate
    @pre_late_text = pre_late_text
    @pre_coming_due_text = pre_coming_due_text
    @completed_text = completed_text
    #matches AdminsController#setup_email_candidate
    @late_events = candidate.get_late_events
    @coming_due_events = candidate.get_coming_due_events
    @completed_events = candidate.get_completed

    mail(
        to: "#{candidate.candidate_sheet.candidate_email}, #{candidate.candidate_sheet.parent_email_1}, #{candidate.candidate_sheet.parent_email_2}",
        subject: 'Confirmation'
    ) do |format|
      format.html
    end

  end

end