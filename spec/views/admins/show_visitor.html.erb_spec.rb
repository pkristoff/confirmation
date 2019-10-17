# frozen_string_literal: true

Warden.test_mode!

feature 'admins/show_visitor.html.erb' do
  include Warden::Test::Helpers

  HOME_PARISH_INIT_VALUE = 'St. Mary Magdalene'
  HOME_INIT_VALUE = '<div><p>Welcome</p></div>'
  HOME_PARISH_CHANGED_VALUE = 'St. Michaels'
  HOME_CHANGED_VALUE = '<div id="foo">ccc yyy</div>'
  ABOUT_INIT_VALUE = '<code>About</code>'
  ABOUT_CHANGED_VALUE = '<div id="bar">ddd zzz</div>'
  CONTACT_INIT_VALUE = '<a href="mailto:stmm.confirmation@kristoffs.com?subject=Help" target="_top">Contact Admin via email stmm.confirmation@kristoffs.com</a>'
  CONTACT_CHANGED_VALUE = '<a href="mailto:stmm.confirmation@kristoffs.com?subject=Help" id="foo" style="bold" target="_top">Contact Admin via email stmm.confirmation@kristoffs.com</a>'
  before(:each) do
    admin = FactoryBot.create(:admin)
    login_as(admin, scope: :admin)

    @visitor = Visitor.visitor(HOME_PARISH_INIT_VALUE, HOME_INIT_VALUE, ABOUT_INIT_VALUE, CONTACT_INIT_VALUE)
  end

  after(:each) do
    Warden.test_reset!
  end

  scenario 'display the visitor home page' do
    visit show_visitor_path
    expect_show_visitor(HOME_PARISH_INIT_VALUE, HOME_INIT_VALUE, ABOUT_INIT_VALUE, CONTACT_INIT_VALUE)
  end

  scenario 'edit the visitor home page' do
    visit show_visitor_path

    fill_in(I18n.t('label.visitor.home_parish'), with: HOME_PARISH_CHANGED_VALUE)
    click_button('top-update-home-parish')

    expect_show_visitor(HOME_PARISH_CHANGED_VALUE, HOME_INIT_VALUE, ABOUT_INIT_VALUE, CONTACT_INIT_VALUE, [[:flash_notice, I18n.t('messages.home_parish_updated')]])

    fill_in(I18n.t('label.visitor.home'), with: HOME_CHANGED_VALUE)
    click_button('top-update-home')

    expect_show_visitor(HOME_PARISH_CHANGED_VALUE, HOME_CHANGED_VALUE, ABOUT_INIT_VALUE, CONTACT_INIT_VALUE, [[:flash_notice, I18n.t('messages.home_updated')]])

    fill_in(I18n.t('label.visitor.about'), with: ABOUT_CHANGED_VALUE)
    click_button('top-update-about')

    expect_show_visitor(HOME_PARISH_CHANGED_VALUE, HOME_CHANGED_VALUE, ABOUT_CHANGED_VALUE, CONTACT_INIT_VALUE, [[:flash_notice, I18n.t('messages.about_updated')]])

    fill_in(I18n.t('label.visitor.contact_information'), with: CONTACT_CHANGED_VALUE)
    click_button('top-update-contact')

    expect_show_visitor(HOME_PARISH_CHANGED_VALUE, HOME_CHANGED_VALUE, ABOUT_CHANGED_VALUE, CONTACT_CHANGED_VALUE, [[:flash_notice, I18n.t('messages.contact_information_updated')]])
  end

  def expect_show_visitor(home_parish, home, about, contact, expected_messages = [])
    expect_messages(expected_messages, page) unless expected_messages.empty?

    expect(page).to have_css("section[id='home_parish']")
    expect(page).to have_css "section[id='home_parish'] form[action='/update_visitor/#{@visitor.id}']"
    expect(page).to have_field(I18n.t('label.visitor.home_parish'), with: home_parish)
    expect(page).to have_css("section[id='home_parish'] input[id='top-update-home-parish'][type='submit'][value='#{I18n.t('views.common.update_home_parish')}']")
    expect(page).to have_css("section[id='home_parish'] input[id='bottom-update-home-parish'][type='submit'][value='#{I18n.t('views.common.update_home_parish')}']")

    expect(page).to have_css("section[id='home']")
    expect(page).to have_css "section[id='home'] form[action='/update_visitor/#{@visitor.id}']"
    expect(page).to have_field(I18n.t('label.visitor.home'), with: home)
    expect(page).to have_css("section[id='home'] input[id='top-update-home'][type='submit'][value='#{I18n.t('views.common.update_home')}']")
    expect(page).to have_css("section[id='home'] input[id='bottom-update-home'][type='submit'][value='#{I18n.t('views.common.update_home')}']")

    expect(page).to have_css("section[id='about']")
    expect(page).to have_css "section[id='about'] form[action='/update_visitor/#{@visitor.id}']"
    expect(page).to have_field(I18n.t('label.visitor.about'), with: about)
    expect(page).to have_css("section[id='about'] input[id='top-update-about'][type='submit'][value='#{I18n.t('views.common.update_about')}']")
    expect(page).to have_css("section[id='about'] input[id='bottom-update-about'][type='submit'][value='#{I18n.t('views.common.update_about')}']")

    expect(page).to have_css("section[id='contact']")
    expect(page).to have_css "section[id='contact'] form[action='/update_visitor/#{@visitor.id}']"
    expect(page).to have_field(I18n.t('label.visitor.contact_information'), with: contact)
    expect(page).to have_css("section[id='contact'] input[id='top-update-contact'][type='submit'][value='#{I18n.t('views.common.update_information_contact')}']")
    expect(page).to have_css("section[id='contact'] input[id='bottom-update-contact'][type='submit'][value='#{I18n.t('views.common.update_information_contact')}']")

    expect(page).to have_css('section', count: 4)
  end
end
