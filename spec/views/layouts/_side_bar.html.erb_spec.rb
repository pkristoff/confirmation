include DeviseHelpers
describe 'layouts/_side_bar.html.erb' do
  context 'visitor no one logged in' do
    it 'nav links layout for visitor' do

      render

      expect(rendered).to have_selector('li', count: 0)
    end
  end
  context 'login as candidate' do
    it 'nav links layout for candidate' do
      candidate = login_candidate

      render

      expect(rendered).to have_selector('li', count: 2)

      expect(rendered).to have_link('Edit Sophia Agusta', href: '/dev/candidates/edit')
      expect(rendered).to have_link('Events Sophia Agusta', href: "/event/#{candidate.id}")
    end
  end
  context 'login as admin' do
    it 'nav links layout for admin' do
      login_admin

      render

      expect(rendered).to have_selector('li', count: 6)
      expect(rendered).to have_link('Add new admin', href: '/admins/sign_up')
      expect(rendered).to have_link('Edit account', href: '/admins/edit')
      expect(rendered).to have_link('Candidates', href: '/candidates')
      expect(rendered).to have_link('Add new candidate', href: '/candidates/new')
      expect(rendered).to have_link('Admins', href: '/admins')
      expect(rendered).to have_link('Other', href: '/candidate_imports/new')
    end
  end
  context 'login as admin and editing a candidate' do
    it 'nav links layout for admin' do
      login_admin

      @resource = FactoryGirl.create(:candidate)

      render

      expect(rendered).to have_selector('li', count: 8)
      expect(rendered).to have_link('Add new admin', href: '/admins/sign_up')
      expect(rendered).to have_link('Edit account', href: '/admins/edit')
      expect(rendered).to have_link('Candidates', href: '/candidates')
      expect(rendered).to have_link('Add new candidate', href: '/candidates/new')
      expect(rendered).to have_link('Admins', href: '/admins')
      expect(rendered).to have_link('Other', href: '/candidate_imports/new')

      expect(rendered).to have_link('Edit Sophia Agusta', href: "/candidates/#{@resource.id}/edit")
      expect(rendered).to have_link('Events Sophia Agusta', href: "/home/#{@resource.id}")
    end
  end
end