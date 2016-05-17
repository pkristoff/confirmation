
describe 'layouts/_navigation.html.erb' do
  it 'navigation layout' do

    render

    expect(rendered).to have_button('Toggle navigation')
    expect(rendered).to have_link('Home', href: '/')

    expect(rendered).to have_selector('li', count: 3)

    expect(rendered).to have_link('About', href: '/pages/about')
    expect(rendered).to have_link('Sign in', href: '/dev/candidates/sign_in')
    expect(rendered).to have_link('Sign in admin', href: '/admins/sign_in')
  end
end