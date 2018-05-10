# frozen_string_literal: true

#
# Send Reset Email Job
#
class SendResetEmailJob
  include SuckerPunch::Job

  # Is this being used
  #
  # === Parameters:
  #
  # * <tt>:candidate</tt> Candidate
  # * <tt>:type</tt> email subject
  # ** <code>:AdminsController::RESET_PASSWORD</code>
  # ** <code>:AdminsController::INITIAL_EMAIL</code>
  #
  def perform(_candidate, type)
    case type
    when AdminsController::RESET_PASSWORD
      raise "Do not do SendResetEmailJob type '#{type}'"
    when AdminsController::INITIAL_EMAIL
      raise "Do not do SendResetEmailJob type '#{type}'"
    else
      raise "SendResetEmailJob unknown type '#{type}'"
    end
  end
end
