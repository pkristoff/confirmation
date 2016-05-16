include DeviseHelpers
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

    expect(rendered).to have_selector("form[id=edit_candidate][action=\"/candidates/#{@resource.id}\"]")

    expect(rendered).to have_field('Candidate', with: 'sophiaagusta', type: 'text')

    expect(rendered).to have_field('First name', with: 'Sophia', type: 'text')
    expect(rendered).to have_field('Last name', with: 'Agusta', type: 'text')

    expect(rendered).to have_field('Grade', with: 10, type: 'number')

    expect(rendered).to have_unchecked_field('Catholic High School', type: 'radio')
    expect(rendered).to have_checked_field('The Way', type: 'radio')

    expect(rendered).to have_field('Candidate email', with: '', type: 'email')
    expect(rendered).to have_field('Parent email 1', with: 'test@example.com', type: 'email')
    expect(rendered).to have_field('Parent email 2', with: '', type: 'email')

    expect(rendered).to have_field('Password', type: 'password')
    expect(rendered).to have_field('Password confirmation', type: 'password')
    expect(rendered).to have_field('Current password', type: 'password')

    expect(rendered).to have_button('Update')

  end
end