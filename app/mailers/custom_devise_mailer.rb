class CustomDeviseMailer < Devise::Mailer

  def headers_for(action, opts)
    headers = super
    headers = headers.merge({
                   to: resource.emails
               })
    @email = headers[:to]
    headers
  end

end