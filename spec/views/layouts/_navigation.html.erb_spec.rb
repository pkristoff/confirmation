
describe 'layouts/_navigation.html.erb' do
  it 'navigation layout' do

    render

    expect(rendered).to have_selector('button', text: 'Toggle navigation')
    expect(rendered).to have_selector('a[href="/"]', text: 'Home')
    expect(rendered).to have_selector('a[href="/pages/about"]', text: 'About')

    expect(rendered).to have_selector('a[href="/candidates/sign_in"]', text: 'Sign in')
    expect(rendered).not_to have_selector('a[href="/candidates/sign_up"]', text: 'Sign up')
    expect(rendered).to have_selector('a[href="/admins/sign_in"]', text: 'Sign in admin')
    expect(rendered).not_to have_selector('a[href="/admins/sign_up"]', text: 'Sign up admin')
  end
end