# frozen_string_literal: true

Warden.test_mode!

feature 'admins/show_visitor.html.erb' do
  include Warden::Test::Helpers

  before(:each) do
    @visitor = FactoryBot.create(:visitor)
    admin = FactoryBot.create(:admin)
    login_as(admin, scope: :admin)

    @visitor.home = '<div><p>Welcome</p></div>'
    @visitor.about = '<code>About</code>'
    @visitor.save
  end

  after(:each) do
    Warden.test_reset!
  end

  scenario 'display the visitor home page' do
    visit show_visitor_path

    expect_show_visitor('<div><p>Welcome</p></div>', '<code>About</code>')
  end

  scenario 'edit the visitor home page' do
    visit show_visitor_path

    fill_in(I18n.t('views.top_bar.home'), with: '<div id="foo">ccc yyy</div>')
    click_button('top-update-home')

    expect_show_visitor('<div id="foo">ccc yyy</div>', '<code>About</code>')

    fill_in(I18n.t('views.top_bar.about'), with: '<div id="bar">ddd zzz</div>')
    click_button('top-update-about')

    expect_show_visitor('<div id="foo">ccc yyy</div>', '<div id="bar">ddd zzz</div>')
  end

  def expect_show_visitor(home, about)
    expect(page).to have_css("section[id='home']")
    expect(page).to have_css "section[id='home'] form[action='/update_visitor/#{@visitor.id}']"
    expect(page).to have_field(I18n.t('views.top_bar.home'), text: home)
    expect(page).to have_css("section[id='home'] input[id='top-update-home'][type='submit'][value='#{I18n.t('views.common.update_home')}']")
    expect(page).to have_css("section[id='home'] input[id='bottom-update-home'][type='submit'][value='#{I18n.t('views.common.update_home')}']")

    expect(page).to have_css("section[id='about']")
    expect(page).to have_css "section[id='about'] form[action='/update_visitor/#{@visitor.id}']"
    expect(page).to have_field(I18n.t('views.top_bar.about'), text: about)
    expect(page).to have_css("section[id='about'] input[id='top-update-about'][type='submit'][value='#{I18n.t('views.common.update_about')}']")
    expect(page).to have_css("section[id='about'] input[id='bottom-update-about'][type='submit'][value='#{I18n.t('views.common.update_about')}']")
  end
end
