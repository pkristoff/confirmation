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
      expect(rendered).to have_link('Events Sophia Agusta', href: "/dev/registrations/event/#{candidate.id}")
    end
  end
  context 'login as admin' do
    it 'nav links layout for admin' do
      login_admin

      render

      expect(rendered).to have_selector('li', count: 7)
      expect(rendered).to have_link(I18n.t('views.nav.add_new_admin'), href: '/admins/sign_up')
      expect(rendered).to have_link(I18n.t('views.nav.edit_account'), href: '/admins/edit')
      expect(rendered).to have_link(I18n.t('views.nav.candidates'), href: '/candidates')
      expect(rendered).to have_link(I18n.t('views.nav.add_new_candidate'), href: '/candidates/new')
      expect(rendered).to have_link(I18n.t('views.nav.admins'), href: '/admins')
      expect(rendered).to have_link(I18n.t('views.nav.events'), href: '/events')
      expect(rendered).to have_link(I18n.t('views.nav.other'), href: '/candidate_imports/new')
    end
  end
  context 'login as admin and editing a candidate' do
    it 'nav links layout for admin' do
      login_admin

      @resource = FactoryGirl.create(:candidate)

      render

      expect(rendered).to have_selector('li', count: 9)
      expect(rendered).to have_link(I18n.t('views.nav.add_new_admin'), href: '/admins/sign_up')
      expect(rendered).to have_link(I18n.t('views.nav.edit_account'), href: '/admins/edit')
      expect(rendered).to have_link(I18n.t('views.nav.candidates'), href: '/candidates')
      expect(rendered).to have_link(I18n.t('views.nav.add_new_candidate'), href: '/candidates/new')
      expect(rendered).to have_link(I18n.t('views.nav.admins'), href: '/admins')
      expect(rendered).to have_link(I18n.t('views.nav.events'), href: '/events')
      expect(rendered).to have_link(I18n.t('views.nav.other'), href: '/candidate_imports/new')

      expect(rendered).to have_link("#{I18n.t('views.nav.edit')} Sophia Agusta", href: "/candidates/#{@resource.id}/edit")
      expect(rendered).to have_link("#{I18n.t('views.nav.events')} Sophia Agusta", href: "/event/#{@resource.id}")
    end
  end
end