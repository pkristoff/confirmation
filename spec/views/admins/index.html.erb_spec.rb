
describe 'admins/index.html.erb' do
  it 'display @admins' do
    assign(:admins, [FactoryGirl.create(:admin)])

    render

    expect(rendered).to have_selector("tr:nth-of-type(1) td:nth-of-type(1)", text: 'Admin Candidate')
  end
end