# frozen_string_literal: true

describe 'layouts/_navigation.html.erb' do
  it 'navigation layout' do
    render

    num_of_common_lis = expect_common_links
    expect(rendered).to have_link(I18n.t('views.top_bar.sign_in', name: '').strip, href: '/dev/candidates/sign_in')
    expect(rendered).to have_link(I18n.t('views.top_bar.sign_in', name: 'admin'), href: '/admins/sign_in')

    expect(rendered).to have_selector('li', count: num_of_common_lis + 2)
  end

  it 'navigation layout admin logged in' do
    admin = login_admin

    render

    num_of_common_lis = expect_common_links
    expect(rendered).to have_link(I18n.t('views.top_bar.sign_out'), href: '/admins/logout')
    expect(rendered).to have_link(I18n.t('views.top_bar.send_grid'), href: 'https://app.sendgrid.com')
    expect(rendered).to have_link(I18n.t('views.top_bar.candidate_checklist'),
                                  href: download_document_path(admin.id, Event::Document::CANDIDATE_CHECKLIST))

    expect(rendered).to have_selector('li', count: num_of_common_lis + 3)
  end

  it 'navigation layout candidate logged in' do
    candidate = login_candidate

    render

    num_of_common_links = expect_common_links
    expect(rendered).to have_link(I18n.t('views.top_bar.sign_out'), href: '/dev/candidates/sign_out')
    expect(rendered).to have_link(I18n.t('views.top_bar.candidate_checklist'),
                                  href: dev_download_document_path(candidate.id, Event::Document::CANDIDATE_CHECKLIST))

    expect(rendered).to have_selector('li', count: num_of_common_links + 2)
  end

  private

  def expect_common_links
    expect(rendered).to have_link(I18n.t('views.top_bar.home'), href: '/')

    expect(rendered).to have_link(I18n.t('views.top_bar.about'), href: '/about')
    expect(rendered).to have_link(I18n.t('views.top_bar.help'), href: '#')
    expect(rendered).to have_link(I18n.t('views.top_bar.contact'), href: contact_path)
    expect(rendered).to have_link(I18n.t('views.top_bar.aboutApp'), href: '/about_app')
    5
  end
end
