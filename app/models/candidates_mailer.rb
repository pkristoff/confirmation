class CandidatesMailer < ActionMailer::Base

  default from: 'confirmation@kristoffs.com'

  def send_candidate(candidate, pre_late_text, pre_verify_text, pre_coming_due_text, completed_text)

    mail(
        to: "#{candidate.candidate_sheet.candidate_email}, #{candidate.candidate_sheet.parent_email_1}, #{candidate.candidate_sheet.parent_email_2}",
        subject: 'Confirmation'
    )

  end

end