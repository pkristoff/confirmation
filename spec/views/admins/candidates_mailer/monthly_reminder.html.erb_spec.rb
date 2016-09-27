
describe 'candidates_mailer/monthly_reminder.html.erb' do

  before(:each) do
    @render_mail_text = true
  end

  it_behaves_like 'shared_monthly_reminder_html_erb'

end
