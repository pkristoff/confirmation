include DeviseHelpers
describe 'admins/registrations/new.html.erb' do
  before do

    @resource_class = Admin

  end
  it 'Form layout' do

    render

    expect(page).to have_selector('p', text: 'This is turned off')

  end
end