class SendResetEmailJob
  include SuckerPunch::Job

  def perform(candidate, type)
    case type
      when AdminsController::RESET_PASSWORD
        candidate.send_reset_password_instructions
      when AdminsController::INITIAL_EMAIL
        candidate.send_confirmation_instructions
      else
        raise "SendResetEmailJob unknown type '#{type}'"
    end
  end
end