# frozen_string_literal: true

#
# Send Reset Email Job
#
class SendResetEmailJob
  include SuckerPunch::Job

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
