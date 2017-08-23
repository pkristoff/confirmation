class SendEmailJob
  include SuckerPunch::Job

  def perform(candidate, text, admin, test=false)
    mailer = if test
               CandidatesMailer.monthly_reminder_test(admin, text)
             else
               CandidatesMailer.monthly_reminder(admin, text)
             end
    logger.info "deliverying to #{candidate.account_name} current_time: #{Time.now}"
    mailer.deliver_now
  end
end