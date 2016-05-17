include DeviseHelpers
include ViewsHelpers
describe 'candidates/edit.html.erb' do

  before(:each) do

    @resource_class = Candidate

    @resource = FactoryGirl.create(:candidate)
    # assign(:candidate, FactoryGirl.create(:candidate))

  end

  #http://stackoverflow.com/questions/10503802/how-can-i-check-that-a-form-field-is-prefilled-correctly-using-capybara
  #https://gist.github.com/steveclarke/2353100

  it 'Form layout' do

    render

    expect_edit_and_new_view(rendered, @resource, "/candidates/#{@resource.id}", 'Update', false, false)

    expect(rendered).to have_selector("form[action=\"/candidates/#{@resource.id}\"]")
    expect(rendered).to have_button('Cancel candidate account')

  end
end