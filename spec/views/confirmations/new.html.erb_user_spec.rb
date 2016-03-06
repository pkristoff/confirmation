include DeviseHelpersForgotPasswordUser
describe 'devise/confirmations/new.html.erb' do
  it 'Form layout' do

    render

    expect(rendered).to have_selector('form[id=new_user]')
    # expect(rendered).to have_selector('input[type=submit]', text: 'Reset Password')
    expect(rendered).to have_selector('label[for=user_email]', text: 'Email')
    expect(rendered).to have_selector('input[id=user_email][value="aaa@bbb.com"]')

    expect(rendered).to have_selector('a[href="/users/sign_in"]', text: 'Log in')
    expect(rendered).to have_selector('a[href="/users/sign_up"]', text: 'Sign up')
    expect(rendered).to have_selector('a[href="/users/password/new"]', text: 'Forgot your password?')

  end
end