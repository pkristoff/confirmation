
describe 'devise/confirmations/new.html.erb' do
  before do
    user = User.new
    def user.pending_reconfirmation?
      true
    end
    def user.unconfirmed_email
      'aaa@bbb.com'
    end
    view.stub(:resource).and_return(user)
    view.stub(:resource_name).and_return(:user)
    view.stub(:devise_mapping).and_return(Devise.mappings[:user])
    view.stub(:confirmation_path).and_return('user_confirmation_path')
  end
  it 'Form layout' do

    render

    expect(rendered).to have_selector('form[id=new_user]')
    # expect(rendered).to have_selector('input[type=submit]', text: 'Reset Password')
    expect(rendered).to have_selector('label[for=user_email]', text: 'Email')
    expect(rendered).to have_selector('input[id=user_email][value="aaa@bbb.com"]')

    expect(rendered).to have_selector('a[href="/users/sign_in"]', text: 'Log in')
    expect(rendered).not_to have_selector('a[href="/users/sign_up"]', text: 'Sign up')
    expect(rendered).to have_selector('a[href="/users/password/new"]', text: 'Forgot your password?')

  end
end