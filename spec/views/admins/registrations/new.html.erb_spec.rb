include DeviseHelpers
describe 'admins/registrations/new.html.erb' do
  before do

    @resource_class = Admin

  end
  it 'Form layout' do

    render

    expect(rendered).to have_selector('form[id=new_admin][action="/admins"]')

    expect(rendered).to have_field('Name', type: 'text')
    expect(rendered).to have_field('Email', with: '', type: 'email')
    expect(rendered).to have_field('Password', type: 'password')
    expect(rendered).to have_field('Password confirmation', type: 'password')
    expect(rendered).to have_button('Sign up')

  end
end