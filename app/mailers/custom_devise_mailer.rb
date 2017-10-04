class CustomDeviseMailer < Devise::Mailer

  def headers_for(action, opts)
    headers = super
    headers = headers.merge({
                   to: resource.emails
               })
    @email = headers[:to]
    headers
  end

  def subject_for(key)
    if key === :reset_password_instructions
      'StMM website for Confirmation Candidates - Reset password instructions'
    elsif key ===:confirmation_instructions
      'StMM website for Confirmation Candidates - User Verification instructions'
    else
      super
    end
  end

end