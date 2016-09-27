
describe 'admins/email_candidate.html.erb' do

  before(:each) do
    @render_mail_text = false
  end

  it_behaves_like 'shared_monthly_reminder_html_erb'

end
