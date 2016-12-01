class SendEmailJob
  include SuckerPunch::Job

  def perform(candidate, pre_late_input, pre_coming_due_input, completed_input)
    mailer = CandidatesMailer.monthly_reminder(candidate, pre_late_input, pre_coming_due_input, completed_input)
    logger.info "deliverying to #{candidate.account_name} current_time: #{Time.now}"
    mailer.deliver_now
  end
end