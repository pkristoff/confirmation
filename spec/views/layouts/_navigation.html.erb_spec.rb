# frozen_string_literal: true

describe 'layouts/_navigation.html.erb' do
  it 'navigation layout' do
    render

    expect_common(false)
    expect(rendered).to have_link(I18n.t('views.top_bar.sign_in', name: '').strip, href: '/dev/candidates/sign_in')
    expect(rendered).to have_link(I18n.t('views.top_bar.sign_in', name: 'admin'), href: '/admins/sign_in')
  end

  it 'navigation layout admin logged in' do
    admin = login_admin

    render

    expect_common(true)
    expect(rendered).to have_link(I18n.t('views.top_bar.sign_out'), href: '/admins/sign_out')
    expect(rendered).to have_link(I18n.t('views.top_bar.send_grid'), href: 'https://app.sendgrid.com')
    expect(rendered).to have_link(I18n.t('views.top_bar.candidate_checklist'), href: download_document_path(admin.id, Event::Document::CANDIDATE_CHECKLIST))
  end

  it 'navigation layout candidate logged in' do
    candidate = login_candidate

    render

    expect_common(false)
    expect(rendered).to have_link(I18n.t('views.top_bar.sign_out'), href: '/dev/candidates/sign_out')
    expect(rendered).to have_link(I18n.t('views.top_bar.candidate_checklist'), href: dev_download_document_path(candidate.id, Event::Document::CANDIDATE_CHECKLIST))
  end

  def expect_common(admin_logged_in)
    expect(rendered).to have_button(I18n.t('views.nav.toggle_navigation'))
    expect(rendered).to have_link(I18n.t('views.top_bar.home'), href: '/')

    expect(rendered).to have_selector('li', count: 6 + (admin_logged_in ? 1 : 0))

    expect(rendered).to have_link(I18n.t('views.top_bar.about'), href: '/pages/about')
    expect(rendered).to have_link(I18n.t('views.top_bar.help'), href: '#')
    expect(rendered).to have_link(I18n.t('views.top_bar.contact_information'), href: contact_information_path)
    expect(rendered).to have_link(I18n.t('views.top_bar.about'), href: about_path)
  end
end
