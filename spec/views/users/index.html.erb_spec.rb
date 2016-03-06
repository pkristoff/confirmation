
describe 'users/index.html.erb' do
  it 'display @users' do
    assign(:users, [FactoryGirl.create(:user)])

    render

    expect(rendered).to have_selector('tr:nth-of-type(1) td:nth-of-type(1)', text: 'User')
  end
end