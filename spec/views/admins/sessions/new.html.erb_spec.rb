include DeviseHelpers
describe 'admins/sessions/new.html.erb' do
  before do

    @resource_class = Admin

  end
  it 'Form layout' do

    render

    expect(rendered).to have_selector('form[id=new_admin][action="/admins/sign_in"]')

    expect(rendered).to have_field('Email', with: '', type: 'email')
    expect(rendered).to have_field('Password', type: 'password')
    expect(rendered).to have_unchecked_field('Remember me')
    expect(rendered).to have_button('Sign in')

  end
end