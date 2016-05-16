include DeviseHelpers
describe 'admins/registrations/edit.html.erb' do
  before do

    @resource_class = Admin
    @resource = FactoryGirl.create(:admin)

  end
  it 'Form layout' do

    render

    expect(rendered).to have_selector('form[id=edit_admin][action="/admins"]')

    expect(rendered).to have_field('Email', with: 'test@example.com', type: 'email')
    expect(rendered).to have_field('Password', type: 'password')
    expect(rendered).to have_field('Password confirmation', type: 'password')
    expect(rendered).to have_field('Current password', type: 'password')
    expect(rendered).to have_button('Update')
    expect(rendered).to have_button('Cancel my account')

  end
end