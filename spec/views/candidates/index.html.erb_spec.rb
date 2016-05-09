
describe 'candidates/index.html.erb' do
  it 'display @candidates' do
    assign(:candidates, [FactoryGirl.create(:candidate)])

    render

    expect(rendered).to have_selector('tr:nth-of-type(1) td:nth-of-type(1)', text: 'Candidate')
  end
end