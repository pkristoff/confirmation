
describe 'devise/passwords/edit.html.erb' do
  before do
    admin = Admin.new
    def admin.pending_reconfirmation?
      true
    end
    def admin.unconfirmed_email
      'aaa@bbb.com'
    end
    view.stub(:resource).and_return(admin)
    view.stub(:resource_name).and_return(:admin)
    view.stub(:devise_mapping).and_return(Devise.mappings[:admin])
    view.stub(:confirmation_path).and_return('admin_confirmation_path')
  end
  it 'Form layout' do

    render

    expect(rendered).to have_selector('form[id=new_admin]')
    expect(rendered).to have_selector('input[id=admin_reset_password_token][type=hidden]')
    expect(rendered).to have_selector('label[for=admin_password]', text: 'New password')
    expect(rendered).to have_selector('input[id=admin_password]', text: '')
    expect(rendered).to have_selector('label[for=admin_password_confirmation]', text: 'Confirm new password')
    expect(rendered).to have_selector('input[id=admin_password_confirmation]', text: '')
    expect(rendered).to have_selector('input[type=submit][name="commit"][value="Change my Password"]')

  end
end