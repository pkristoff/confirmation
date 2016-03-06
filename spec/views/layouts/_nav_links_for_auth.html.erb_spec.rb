
describe 'layouts/_messages.html.erb' do
  before do
    view.stub(:flash).and_return([['notice', 'nnn'],['error', 'errormessage'],['error', 'errormessage2']])
  end
  it 'Form layout' do

    render

    puts rendered

    expect(rendered).to have_selector('div[id=flash_notice]', text: 'nnn')
    expect(rendered).to have_selector('div[id=flash_error]', text: 'errormessage')
    expect(rendered).to have_selector('div[id=flash_error]', text: 'errormessage2')
  end
end