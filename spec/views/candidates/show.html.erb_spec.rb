
describe 'candidates/show.html.erb' do

  before(:each) do

    assign(:candidate, FactoryGirl.create(:candidate))

  end

  it 'display @candidate' do

    render

    expect(rendered).to have_selector('p', count: 3)
    expect(rendered).to have_selector('p', text: 'Id: sophiaagusta')
    expect(rendered).to have_selector('p', text: 'Parent Email: test@example.com')
    expect(rendered).to have_selector('p', text: 'First Name: Sophia')

  end
end