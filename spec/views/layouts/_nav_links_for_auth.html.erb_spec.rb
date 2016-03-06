describe 'layouts/_nav_links_for_auth.html.erb' do
  context "visitor no one logged in" do
    it 'nav links layout for visitor' do

      render

      expect(rendered).to have_selector('a[href="/users/sign_in"]', text: 'Sign in')
      expect(rendered).to have_selector('a[href="/users/sign_up"]', text: 'Sign up')
      expect(rendered).to have_selector('a[href="/admins/sign_in"]', text: 'Sign in admin')
      expect(rendered).to have_selector('a[href="/admins/sign_up"]', text: 'Sign up admin')
    end
  end
  context "login as user" do
    login_user
    it 'nav links layout for user' do

      render

      expect(rendered).to have_selector('a[href="/users/edit"]', text: 'Edit account')
      expect(rendered).to have_selector('a[href="/users/sign_out"]', text: 'Sign out')
    end
  end
  context "login as admin" do
    login_admin
    it 'nav links layout for admin' do

      render

      expect(rendered).to have_selector('a[href="/admins/edit"]', text: 'Edit account')
      expect(rendered).to have_selector('a[href="/admins/sign_out"]', text: 'Sign out')
      expect(rendered).to have_selector('a[href="/users"]', text: 'Users')
    end
  end
end