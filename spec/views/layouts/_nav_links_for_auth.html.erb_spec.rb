describe 'layouts/_nav_links_for_auth.html.erb' do
  context 'visitor no one logged in' do
    it 'nav links layout for visitor' do

      render

      expect(rendered).to have_link('Sign in', href: '/dev/candidates/sign_in')
      expect(rendered).not_to have_link('Sign up', href: '/dev/candidates/sign_up')
      expect(rendered).to have_link('Sign in admin', href: '/admins/sign_in')
      expect(rendered).not_to have_link('Sign up admin', href: '/admins/sign_up')
    end
  end
  context 'login as candidate' do
    it 'nav links layout for candidate' do
      login_candidate

      render

      expect(rendered).to have_link('Edit account', href: '/dev/candidates/edit')
      expect(rendered).to have_link('Sign out', href: '/dev/candidates/sign_out')
      expect(rendered).not_to have_link('Sign up admin', href: '/admins/sign_up')
    end
  end
  context 'login as admin' do
    it 'nav links layout for admin' do
      login_admin

      render

      expect(rendered).to have_link('Edit account', href: '/admins/edit')
      expect(rendered).to have_link('Sign out', href: '/admins/sign_out')
      expect(rendered).to have_link('Admins', href: '/admins')
      expect(rendered).to have_link('Sign up admin', href: '/admins/sign_up')
      expect(rendered).to have_link('Candidates', href: '/candidates')
    end
  end
end