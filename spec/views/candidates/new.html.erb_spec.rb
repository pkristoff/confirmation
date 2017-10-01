include DeviseHelpers
include ViewsHelpers
describe 'candidates/new.html.erb' do
  it 'Form layout' do

    @resource_class = Candidate

    render

    expect(page).to have_selector('p', text: 'This is turned off')

  end
end