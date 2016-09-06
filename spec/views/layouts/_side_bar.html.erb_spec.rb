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

      expect(rendered).to have_selector('li', count: 9)

      expect(rendered).to have_link(I18n.t('events.candidate_covenant_agreement'), href: "/dev/sign_agreement.#{candidate.id}")
      expect(rendered).to have_link(I18n.t('events.candidate_information_sheet'), href: "/dev/candidate_sheet.#{candidate.id}")
      expect(rendered).to have_link(I18n.t('events.baptismal_certificate'), href: "/dev/event_with_picture/#{candidate.id}/#{Event::Route::BAPTISMAL_CERTIFICATE}")
      expect(rendered).to have_link(I18n.t('events.sponsor_covenant'), href: "/dev/event_with_picture/#{candidate.id}/#{Event::Route::SPONSOR_COVENANT}")
      expect(rendered).to have_link(I18n.t('events.confirmation_name'), href: "/dev/event_with_picture/#{candidate.id}/#{Event::Route::CONFIRMATION_NAME}")
      expect(rendered).to have_link(I18n.t('views.nav.sponsor_agreement'), href: "/dev/sponsor_agreement.#{candidate.id}")
      expect(rendered).to have_link(I18n.t('views.nav.christian_ministry'), href: "/dev/event_with_picture/#{candidate.id}/#{Event::Route::CHRISTIAN_MINISTRY}")
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

      expect(rendered).to have_selector('li', count: 16)
      expect(rendered).to have_link(I18n.t('views.nav.add_new_admin'), href: '/admins/sign_up')
      expect(rendered).to have_link(I18n.t('views.nav.edit_account'), href: '/admins/edit')
      expect(rendered).to have_link(I18n.t('views.nav.candidates'), href: '/candidates')
      expect(rendered).to have_link(I18n.t('views.nav.add_new_candidate'), href: '/candidates/new')
      expect(rendered).to have_link(I18n.t('views.nav.admins'), href: '/admins')
      expect(rendered).to have_link(I18n.t('views.nav.events'), href: '/events')
      expect(rendered).to have_link(I18n.t('views.nav.other'), href: '/candidate_imports/new')

      expect(rendered).to have_link("#{I18n.t('views.nav.edit')} Sophia Agusta", href: "/candidates/#{@resource.id}/edit")
      expect(rendered).to have_link("#{I18n.t('views.nav.events')} Sophia Agusta", href: "/event/#{@resource.id}")
      expect(rendered).to have_link("#{I18n.t('events.candidate_covenant_agreement')} Sophia Agusta", href: "/sign_agreement.#{@resource.id}")
      expect(rendered).to have_link("#{I18n.t('events.candidate_information_sheet')} Sophia Agusta", href: "/candidate_sheet.#{@resource.id}")
      expect(rendered).to have_link("#{I18n.t('events.baptismal_certificate')} Sophia Agusta", href: "/event_with_picture/#{@resource.id}/baptismal_certificate")
      expect(rendered).to have_link("#{I18n.t('events.sponsor_covenant')} Sophia Agusta", href: "/event_with_picture/#{@resource.id}/sponsor_covenant")
      expect(rendered).to have_link("#{I18n.t('events.confirmation_name')} Sophia Agusta", href: "/event_with_picture/#{@resource.id}/confirmation_name")
      expect(rendered).to have_link("#{I18n.t('views.nav.sponsor_agreement')} Sophia Agusta", href: "/sponsor_agreement.#{@resource.id}")
      expect(rendered).to have_link("#{I18n.t('views.nav.christian_ministry')} Sophia Agusta", href: "/event_with_picture/#{@resource.id}/christian_ministry")
    end
  end
end