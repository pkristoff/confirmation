include DeviseHelpersNew
describe 'devise/registrations/new.html.erb' do
  it 'Form layout' do

    render

    expect(rendered).to have_selector('form[id=new_user]') do |form|
      expect(form).to have_selector('input', :type => 'submit')
      expect(form).to have_selector('label[for=user_name]', text: 'Name')
      expect(form).to have_selector('input[id=user_name]', text: '')
      expect(form).to have_selector('label[for=user_email]', text: 'Email')
      expect(form).to have_selector('input[id=user_email]', text: '')
      expect(form).to have_selector('label[for=user_password]', text: 'Password')
      expect(form).to have_selector('input[id=user_password]', text: '')
      expect(form).to have_selector('label[for=user_password_confirmation]', text: 'Password confirmation')
      expect(form).to have_selector('input[id=user_password_confirmation]', text: '')
    end

  end
end