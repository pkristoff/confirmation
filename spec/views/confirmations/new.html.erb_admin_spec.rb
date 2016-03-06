
describe 'devise/confirmations/new.html.erb' do
  before do
    admin = Admin.new
    def admin.pending_reconfirmation?
      true
    end
    def admin.unconfirmed_email
      'bbb@bbb.com'
    end
    view.stub(:resource).and_return(admin)
    view.stub(:resource_name).and_return(:admin)
    view.stub(:devise_mapping).and_return(Devise.mappings[:admin])
    view.stub(:confirmation_path).and_return('admin_confirmation_path')
  end
  it 'Form layout' do

    render

    expect(rendered).to have_selector('form[id=new_admin]')
    # expect(rendered).to have_selector('input[type=submit]', text: 'Reset Password')
    expect(rendered).to have_selector('label[for=admin_email]', text: 'Email')
    expect(rendered).to have_selector('input[id=admin_email][value="bbb@bbb.com"]')

    expect(rendered).to have_selector('a[href="/admins/sign_in"]', text: 'Log in')
    expect(rendered).to have_selector('a[href="/admins/sign_up"]', text: 'Sign up')
    expect(rendered).to have_selector('a[href="/admins/password/new"]', text: 'Forgot your password?')

  end
end