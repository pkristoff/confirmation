class SendResetEmailJob
  include SuckerPunch::Job

  def perform(candidate, type)
    if type === AdminsController::RESET_PASSWORD
      candidate.send_reset_password_instructions
    elsif type === AdminsController::INITIAL_EMAIL
      candidate.send_confirmation_instructions
      candidate.send_reset_password_instructions
    end
  end
end