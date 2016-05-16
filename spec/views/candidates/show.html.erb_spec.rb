
describe 'candidates/show.html.erb' do

  before(:each) do

    assign(:candidate, FactoryGirl.create(:candidate))

  end

  it 'display @candidate' do

    render

    expect(rendered).to have_selector('p', count: 8)
    expect(rendered).to have_selector('p', text: 'Id: sophiaagusta')
    expect(rendered).to have_selector('p', text: 'First name: Sophia')
    expect(rendered).to have_selector('p', text: 'Last name: Agusta')
    expect(rendered).to have_selector('p', text: 'Attending: The Way')
    expect(rendered).to have_selector('p', text: 'Grade: 10')
    expect(rendered).to have_selector('p', text: 'Candidate email: ')
    expect(rendered).to have_selector('p', text: 'Parent email 1: test@example.com')
    expect(rendered).to have_selector('p', text: 'Parent email 2: ')

  end
end