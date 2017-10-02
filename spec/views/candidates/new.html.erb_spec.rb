include DeviseHelpers
include ViewsHelpers
describe 'candidates/new.html.erb' do
  it 'Form layout' do

    @resource_class = Candidate

    render

    expect(rendered).to have_selector('p', text: 'This has been turned off')

  end
end