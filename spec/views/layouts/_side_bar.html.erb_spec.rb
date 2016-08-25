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

      expect(rendered).to have_selector('li', count: 6)

      expect(rendered).to have_link(I18n.t('views.nav.sign_agreement'), href: "/dev/sign_agreement.#{candidate.id}")
      expect(rendered).to have_link(I18n.t('views.nav.candidate_sheet'), href: "/dev/candidate_sheet.#{candidate.id}")
      expect(rendered).to have_link(I18n.t('views.nav.upload_baptismal_certificate'), href: "/dev/upload_baptismal_certificate.#{candidate.id}")
      expect(rendered).to have_link(I18n.t('views.nav.sponsor_covenant'), href: "/dev/upload_sponsor_covenant.#{candidate.id}")
      expect(rendered).to have_link(I18n.t('views.nav.edit'), href: '/dev/candidates/edit')
      expect(rendered).to have_link(I18n.t('views.nav.events'), href: "/dev/registrations/event/#{candidate.id}")
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

      expect(rendered).to have_selector('li', count: 13)
      expect(rendered).to have_link(I18n.t('views.nav.add_new_admin'), href: '/admins/sign_up')
      expect(rendered).to have_link(I18n.t('views.nav.edit_account'), href: '/admins/edit')
      expect(rendered).to have_link(I18n.t('views.nav.candidates'), href: '/candidates')
      expect(rendered).to have_link(I18n.t('views.nav.add_new_candidate'), href: '/candidates/new')
      expect(rendered).to have_link(I18n.t('views.nav.admins'), href: '/admins')
      expect(rendered).to have_link(I18n.t('views.nav.events'), href: '/events')
      expect(rendered).to have_link(I18n.t('views.nav.other'), href: '/candidate_imports/new')

      expect(rendered).to have_link("#{I18n.t('views.nav.edit')} Sophia Agusta", href: "/candidates/#{@resource.id}/edit")
      expect(rendered).to have_link("#{I18n.t('views.nav.events')} Sophia Agusta", href: "/event/#{@resource.id}")
      expect(rendered).to have_link("#{I18n.t('views.nav.sign_agreement')} Sophia Agusta", href: "/sign_agreement.#{@resource.id}")
      expect(rendered).to have_link("#{I18n.t('views.nav.candidate_sheet')} Sophia Agusta", href: "/candidate_sheet.#{@resource.id}")
      expect(rendered).to have_link("#{I18n.t('views.nav.upload_baptismal_certificate')} Sophia Agusta", href: "/upload_baptismal_certificate.#{@resource.id}")
      expect(rendered).to have_link("#{I18n.t('views.nav.sponsor_covenant')} Sophia Agusta", href: "/upload_sponsor_covenant.#{@resource.id}")
    end
  end
end