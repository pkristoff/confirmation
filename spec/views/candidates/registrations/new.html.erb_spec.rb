include DeviseHelpers
include ViewsHelpers
describe 'candidates/registrations/new.html.erb' do
  it 'Form layout' do

    @resource_class = Candidate

    render

    expect_edit_and_new_view(rendered, @resource, '/dev/candidates', 'Sign up', true, true)

  end
end