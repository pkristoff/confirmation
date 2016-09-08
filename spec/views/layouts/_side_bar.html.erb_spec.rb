include DeviseHelpers

describe 'layouts/_side_bar.html.erb' do

  before(:each) do


    @admin_link_names_in_order = [
        [I18n.t('views.nav.add_new_admin'), '/admins/sign_up'],
        [I18n.t('views.nav.edit_account'), '/admins/edit'],
        [I18n.t('views.nav.candidates'), '/candidates'],
        [I18n.t('views.nav.add_new_candidate'), '/candidates/new'],
        [I18n.t('views.nav.admins'), '/admins'],
        [I18n.t('views.nav.events'), '/events'],
        [I18n.t('views.nav.other'), '/candidate_imports/new']
    ]

    @candidate_link_names_in_order = [
        [I18n.t('events.candidate_covenant_agreement'), '<dev>/sign_agreement.<id>'],
        [I18n.t('events.candidate_information_sheet'), '<dev>/candidate_sheet.<id>'],
        [I18n.t('events.baptismal_certificate'), '<dev>/event_with_picture/<id>/baptismal_certificate'],
        [I18n.t('events.sponsor_covenant'), '<dev>/event_with_picture/<id>/sponsor_covenant'],
        [I18n.t('events.confirmation_name'), '<dev>/event_with_picture/<id>/confirmation_name'],
        [I18n.t('events.sponsor_agreement'), '<dev>/sponsor_agreement.<id>'],
        [I18n.t('events.christian_ministry'), '<dev>/event_with_picture/<id>/christian_ministry'],
        [I18n.t('views.nav.edit'), '/candidates/<id>/edit', '<dev>/candidates/edit'],
        [I18n.t('views.nav.events'), '/event/<id>', '/dev/registrations/event/<id>']
    ]

  end


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

      expect_links_in_order(@candidate_link_names_in_order, 'candidate-sidebar', '/dev', candidate.id.to_s)

      expect(rendered).to have_link(I18n.t('events.candidate_covenant_agreement'), href: "/dev/sign_agreement.#{candidate.id}")
      expect(rendered).to have_link(I18n.t('events.candidate_information_sheet'), href: "/dev/candidate_sheet.#{candidate.id}")
      expect(rendered).to have_link(I18n.t('events.baptismal_certificate'), href: "/dev/event_with_picture/#{candidate.id}/#{Event::Route::BAPTISMAL_CERTIFICATE}")
      expect(rendered).to have_link(I18n.t('events.sponsor_covenant'), href: "/dev/event_with_picture/#{candidate.id}/#{Event::Route::SPONSOR_COVENANT}")
      expect(rendered).to have_link(I18n.t('events.confirmation_name'), href: "/dev/event_with_picture/#{candidate.id}/#{Event::Route::CONFIRMATION_NAME}")
      expect(rendered).to have_link(I18n.t('events.sponsor_agreement'), href: "/dev/sponsor_agreement.#{candidate.id}")
      expect(rendered).to have_link(I18n.t('events.christian_ministry'), href: "/dev/event_with_picture/#{candidate.id}/#{Event::Route::CHRISTIAN_MINISTRY}")
      expect(rendered).to have_link(I18n.t('views.nav.edit'), href: '/dev/candidates/edit')
      expect(rendered).to have_link(I18n.t('views.nav.events'), href: "/dev/registrations/event/#{candidate.id}")
    end
  end

  context 'login as admin' do
    it 'nav links layout for admin' do
      login_admin

      render

      expect_links_in_order(@admin_link_names_in_order, 'admin-sidebar', '')

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

      expect_links_in_order(@admin_link_names_in_order, 'admin-sidebar', '')

      expect(rendered).to have_selector("p[class='sidebar-header no-link']", text: 'Candidate: Sophia Agusta')

      expect_links_in_order(@candidate_link_names_in_order, 'candidate-sidebar', '', @resource.id.to_s)
    end
  end

  def expect_links_in_order(link_names_in_order, sidebar_id, dev, candidate_id='')
    link_names_in_order.each_with_index do |info, index|
      event_name = info[0]
      if (info.size === 3) && !dev.empty?
        href = info[2].gsub('<dev>', dev)
      else
        href = info[1].gsub('<dev>', dev)
      end
      href = href.gsub('<id>', candidate_id)
      expect(rendered).to have_selector("ul[id='#{sidebar_id}'] li:nth-child(#{index+1})", text: event_name)
      expect(rendered).to have_link(event_name, href: href)
    end
    expect(rendered).to have_selector("ul[id='#{sidebar_id}'] li", count: link_names_in_order.size)
  end
end