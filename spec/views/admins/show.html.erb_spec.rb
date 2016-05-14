
describe 'admins/show.html.erb' do

  before(:each) do

    assign(:admin, FactoryGirl.create(:admin))

  end

  it 'display @admin' do

    render

    expect(rendered).to have_selector('p', count: 2)
    expect(rendered).to have_selector('p', text: 'Name: Admin Candidate')
    expect(rendered).to have_selector('p', text: 'Email: test@example.com')

  end
end