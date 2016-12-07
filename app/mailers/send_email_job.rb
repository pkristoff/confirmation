class SendEmailJob
  include SuckerPunch::Job

  def perform(candidate, subject, pre_late_input, pre_coming_due_input, completed_input, closing_text, salutation_text, from_text)
    mailer = CandidatesMailer.monthly_reminder(candidate, subject, pre_late_input, pre_coming_due_input, completed_input, closing_text, salutation_text, from_text)
    logger.info "deliverying to #{candidate.account_name} current_time: #{Time.now}"
    mailer.deliver_now
  end
end