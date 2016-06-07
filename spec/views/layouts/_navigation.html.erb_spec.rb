
describe 'layouts/_navigation.html.erb' do
  it 'navigation layout' do

    render

    expect(rendered).to have_button(I18n.t('views.nav.toggle_navigation'))
    expect(rendered).to have_link(I18n.t('views.common.home'), href: '/')

    expect(rendered).to have_selector('li', count: 3)

    expect(rendered).to have_link(I18n.t('views.common.about'), href: '/pages/about')
    expect(rendered).to have_link(I18n.t('views.common.sign_in', name: '').strip, href: '/dev/candidates/sign_in')
    expect(rendered).to have_link(I18n.t('views.common.sign_in', name: 'admin'), href: '/admins/sign_in')
  end
end