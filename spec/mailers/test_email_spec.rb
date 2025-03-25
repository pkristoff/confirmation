# frozen_string_literal: true

require 'sendgrid-ruby'

describe 'Mail' do
  include SendGrid
  it 'send_emil orig' do
    from = SendGrid::Email.new(email: 'confirmation@stmm.net')
    to = SendGrid::Email.new(email: 'paul.kristoff@kristoffs.com')
    subject = 'Sending with SendGrid is Fun'
    content = SendGrid::Content.new(type: 'text/plain', value: 'and easy to do anywhere, even with Ruby')
    mail = SendGrid::Mail.new(from, subject, to, content)

    sg = SendGrid::API.new(api_key: ENV.fetch('SENDGRID_API_KEY', nil))
    response = sg.client.mail._('send').post(request_body: mail.to_json)
    expect(response.status_code).to eq('202')
  end
end
