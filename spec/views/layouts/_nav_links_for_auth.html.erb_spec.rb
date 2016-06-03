describe 'layouts/_nav_links_for_auth.html.erb' do
  context 'visitor no one logged in' do
    it 'nav links layout for visitor' do

      render

      expect(rendered).to have_selector('li', count: 2)

      expect(rendered).to have_link('Sign in', href: '/dev/candidates/sign_in')
      expect(rendered).to have_link('Sign in admin', href: '/admins/sign_in')
    end
  end
  context 'login as candidate' do
    it 'nav links layout for candidate' do
      login_candidate

      render

      expect(rendered).to have_selector('li', count: 1)

      expect(rendered).to have_link('Sign out', href: '/dev/candidates/sign_out')
    end
  end
  context 'login as admin' do
    it 'nav links layout for admin' do
      login_admin

      render

      expect(rendered).to have_selector('li', count: 1)
      expect(rendered).to have_link('Sign out', href: '/admins/sign_out')
    end
  end
end