# frozen_string_literal: true

describe 'layouts/_side_bar.html.erb' do
  include DeviseHelpers
  before(:each) do
    @admin_link_names_in_order = [
      [I18n.t('views.nav.add_new_admin'), '/admins/sign_up'],
      [I18n.t('views.nav.edit_account'), '/admins/edit'],
      [I18n.t('views.nav.candidates'), '/candidates'],
      [I18n.t('views.nav.adhoc_mailing'), '/adhoc_mailing'],
      [I18n.t('views.nav.monthly_mass_mailing'), '/monthly_mass_mailing'],
      [I18n.t('views.nav.add_new_candidate'), '/candidates/new'],
      [I18n.t('views.nav.admins'), '/admins'],
      [I18n.t('views.nav.events'), '/edit_multiple_confirmation_events'],
      [I18n.t('views.nav.visitors'), '/show_visitor'],
      [I18n.t('views.nav.other'), '/candidate_imports/new'],
      ['Export']
    ]

    @admin_export_link_names_in_order = [
      [I18n.t('views.nav.export_confirmation_name'), '/export_lists/confirmation_name'],
      [I18n.t('views.nav.export_attend_retreat_title', home_parish: Visitor.home_parish), '/export_lists/retreat'],
      [I18n.t('views.nav.export_baptized_at_home_parish_title', home_parish: Visitor.home_parish), '/export_lists/baptism'],
      [I18n.t('views.nav.export_sponsor_at_home_parish_title', home_parish: Visitor.home_parish), '/export_lists/sponsor'],
      [I18n.t('views.nav.export_candidate_event_status_title'), '/export_lists/events'],
      [I18n.t('views.nav.pdf_baptismal_name'), '/export_lists/bap_name']
    ]

    @candidate_link_names_in_order = [
      [I18n.t('label.sidebar.candidate_covenant_agreement'), '<dev>/sign_agreement.<id>'],
      [I18n.t('label.sidebar.candidate_information_sheet'), '<dev>/candidate_sheet.<id>'],
      [I18n.t('label.sidebar.baptismal_certificate'), '<dev>/event_with_picture/<id>/baptismal_certificate'],
      [I18n.t('label.sidebar.sponsor_covenant'), '<dev>/event_with_picture/<id>/sponsor_covenant'],
      [I18n.t('label.sidebar.confirmation_name'), '<dev>/pick_confirmation_name.<id>'],
      [I18n.t('label.sidebar.christian_ministry'), '<dev>/christian_ministry.<id>'],
      [I18n.t('label.sidebar.retreat_verification'), '<dev>/event_with_picture/<id>/retreat_verification'],
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

      expect_links_in_order(@candidate_link_names_in_order, 'candidate-sidebar', '/dev', 9, candidate.id.to_s)
    end
  end

  context 'login as admin' do
    it 'nav links layout for admin' do
      login_admin

      render

      expect_links_in_order(@admin_link_names_in_order, 'admin-sidebar', '', 17)

      expect_links_in_order(@admin_export_link_names_in_order, 'export-sidebar', '', 6)

      expect(rendered).to_not have_selector('p[id="candidate: Sophia Agusta"]')
    end
  end

  context 'login as admin and editing a candidate' do
    it 'nav links layout for admin' do
      login_admin

      @resource = FactoryBot.create(:candidate)
      @candidate_link_names_in_order = @candidate_link_names_in_order.insert(0, [I18n.t('label.sidebar.candidate_note'), '/candidate_note.<id>'])

      render

      expect_links_in_order(@admin_link_names_in_order, 'admin-sidebar', '', 27) # +1 is for candidate

      expect_links_in_order(@admin_export_link_names_in_order, 'export-sidebar', '', 6)
      expect(rendered).to have_selector('p[id="candidate"]', text: 'Candidate: Sophia Agusta')

      expect_links_in_order(@candidate_link_names_in_order, 'candidate-sidebar', '', 10, @resource.id.to_s)
    end
  end

  def expect_links_in_order(link_names_in_order, sidebar_id, dev, total_num_links, candidate_id = '')
    link_names_in_order.each_with_index do |info, index|
      event_name = info[0]
      href = if (info.size == 3) && !dev.empty?
               info[2].gsub('<dev>', dev)
             elsif info.size == 2
               info[1].gsub('<dev>', dev)
             end
      href = href.gsub('<id>', candidate_id) unless href.nil?

      event_name = event_name.gsub(/([\w\s]{17}).+/, '\1...') if event_name.size > SideBar::TRUNCATELENGTH
      expect(rendered).to have_selector("ul[id='#{sidebar_id}'] li:nth-child(#{index + 1})", text: event_name)
      expect(rendered).to have_link(event_name, href: href) unless href.nil?
    end
    expect(rendered).to have_selector("ul[id='#{sidebar_id}'] li", count: total_num_links)
  end
end
