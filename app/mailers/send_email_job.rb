# frozen_string_literal: true

#
# Send Email Job
#
class SendEmailJob
  include SuckerPunch::Job

  # Is this being used
  #
  # === Parameters:
  #
  # * <tt>:candidate</tt> To
  # * <tt>:text</tt> body
  # * <tt>:admin</tt> from
  # * <tt>:test</tt>
  #
  def perform(candidate, text, admin, test: false)
    mailer = if text.body_text.nil?
               if test
                 CandidatesMailer.monthly_reminder_test(admin, text)
               else
                 CandidatesMailer.monthly_reminder(admin, text)
               end
             elsif test
               CandidatesMailer.adhoc_test(admin, text)
             else
               CandidatesMailer.adhoc(admin, text)
             end
    logger.info "deliverying to #{candidate.account_name} current_time: #{Time.now.in_time_zone}"
    mailer.deliver_now
  end
end
