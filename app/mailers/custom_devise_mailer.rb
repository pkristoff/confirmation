# frozen_string_literal: true

#
# Custom Devise Mailer tasks
#
class CustomDeviseMailer < Devise::Mailer
  # set up email addresses in header
  #
  # === Parameters:
  #
  # * <tt>:action</tt> legal values
  # * <tt>:opts</tt> legal values
  #
  def headers_for(action, opts)
    # adds admin so it is asvailable for mail expansion
    @admin = opts[:admin]
    headers = super

    headers = headers.merge(to: resource.email) if resource.instance_of?(Admin)
    # always send email to admin
    headers = headers.merge(to: resource.emails, bcc: @admin.email) unless resource.instance_of?(Admin)
    @email = headers[:to]
    headers
  end

  # default subjects for enail messages
  #
  # === Parameters:
  #
  # * <tt>:key</tt> legal values
  # ** <code>:reset_password_instructions</code> when sending reset message
  # ** <code>:confirmation_instructions</code> when sending initial welcome message
  #
  def subject_for(key)
    case key
    when :reset_password_instructions
      "#{Visitor.home_parish} website for Confirmation Candidates - Reset password instructions"
    when :confirmation_instructions
      "#{Visitor.home_parish} website for Confirmation Candidates - User Verification instructions"
    else
      super
    end
  end
end
