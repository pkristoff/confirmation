# frozen_string_literal: true

Warden.test_mode!

feature 'admins/show_visitor.html.erb' do
  include Warden::Test::Helpers

  before(:each) do
    @visitor = FactoryBot.create(:visitor)
    admin = FactoryBot.create(:admin)
    login_as(admin, scope: :admin)
  end

  after(:each) do
    Warden.test_reset!
  end

  scenario 'display the visitor home page' do
    @visitor.home = '<div><p>Welcome</p></div>'
    @visitor.save
    visit show_visitor_path

    expect_show_visitor('<div><p>Welcome</p></div>')
  end

  scenario 'edit the visitor home page' do
    @visitor.home = '<div><p>Welcome</p></div>'
    @visitor.save

    visit show_visitor_path

    fill_in(I18n.t('views.top_bar.home'), with: '<div id="foo">ccc yyy</div>')
    click_button('top-update')

    expect_show_visitor('<div id="foo">ccc yyy</div>')
  end

  def expect_show_visitor(home)
    expect(page).to have_css("section[id='home']")
    expect(page).to have_css "section[id='home'] form[action='/update_visitor/#{@visitor.id}']"
    expect(page).to have_field(I18n.t('views.top_bar.home'), text: home)
    expect(page).to have_css("section[id='home'] input[id='top-update'][type='submit'][value='#{I18n.t('views.common.update_home')}']")
    expect(page).to have_css("section[id='home'] input[id='bottom-update'][type='submit'][value='#{I18n.t('views.common.update_home')}']")
  end
end
