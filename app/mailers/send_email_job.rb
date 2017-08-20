class SendEmailJob
  include SuckerPunch::Job

  def perform(candidate, text, admin, test=false)
    if test
      mailer = CandidatesMailer.monthly_reminder_test(admin, text)
    else
      mailer = CandidatesMailer.monthly_reminder(candidate, admin, text)
    end
    logger.info "deliverying to #{candidate.account_name} current_time: #{Time.now}"
    mailer.deliver_now
  end
end