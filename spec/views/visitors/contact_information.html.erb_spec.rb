
describe 'visitors/contact_information.html.erb' do
  it 'navigation layout' do

    render

    expect(rendered).to have_selector('p', count: 2)
    expect_common
  end

  it 'navigation layout admin logged in' do

    admin = login_admin

    render

    expect(rendered).to have_selector('p', count: 3)
    expect_common
    expect(rendered).to have_css('p', text: 'Phone:')
  end

  it 'navigation layout candidate logged in' do

    candidate = login_candidate

    render

    expect(rendered).to have_selector('p', count: 3)
    expect_common
    expect(rendered).to have_css('p', text: 'Phone:')
  end

  def expect_common
    expect(rendered).to have_css('p', text: t('views.top_bar.contact_information'))
    expect(rendered).to have_link(I18n.t('views.top_bar.contact_admin'), href: I18n.t('views.top_bar.contact_admin_mail'))

  end
end

