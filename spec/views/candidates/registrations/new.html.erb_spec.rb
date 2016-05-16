include DeviseHelpers
describe 'candidates/registrations/new.html.erb' do
  it 'Form layout' do

    @resource_class = Candidate

    render

    expect(rendered).to have_selector('form[id=new_candidate][action="/dev/candidates"]')

    expect(rendered).to have_field('Candidate', type: 'text')

    expect(rendered).to have_field('First name', with: '', type: 'text')
    expect(rendered).to have_field('Last name', with: '', type: 'text')

    expect(rendered).to have_field('Grade', type: 'number')

    expect(rendered).to have_unchecked_field('Catholic High School', type: 'radio')
    expect(rendered).to have_checked_field('The Way', type: 'radio')

    expect(rendered).to have_field('Candidate email', with: '', type: 'email')
    expect(rendered).to have_field('Parent email 1', with: '', type: 'email')
    expect(rendered).to have_field('Parent email 2', with: '', type: 'email')

    expect(rendered).to have_field('Password', type: 'password')
    expect(rendered).to have_field('Password confirmation', type: 'password')
    expect(rendered).to have_field('Current password', type: 'password')

    expect(rendered).to have_button('Sign up')

  end
end