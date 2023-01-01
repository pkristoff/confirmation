# frozen_string_literal: true

Warden.test_mode!

# Feature: Admin edit
#   As a admin
#   I want to edit my admin profile
#   So I can change my email address
describe 'Admin edit', :devise do
  include Warden::Test::Helpers

  before do
    FactoryBot.create(:visitor)
  end

  after do
    Warden.test_reset!
  end

  it 'edit myself' do
    me = FactoryBot.create(:admin)
    login_as(me, scope: :admin)
    visit edit_admin_path(me)
    fill_in(I18n.t('activerecord.attributes.admin.contact_name'), with: 'Paul')
    fill_in(I18n.t('activerecord.attributes.admin.contact_phone'), with: '919-555-5555')
    fill_in(I18n.t('activerecord.attributes.admin.email'), with: 'xxx@yyy.com')
    click_button('update')

    # check edit admin is showing
    expect_edit_page(page, Admin.find_by(id: me.id), {})
    expect_messages([[:flash_notice, I18n.t('messages.flash.notice.common.updated')]])
  end

  it 'validation Contact name' do
    me = FactoryBot.create(:admin)
    login_as(me, scope: :admin)
    visit edit_admin_path(me)
    fill_in(I18n.t('activerecord.attributes.admin.contact_name'), with: '')
    click_button('update')

    expect_messages([[:flash_alert, I18n.t('messages.flash.alert.admin.not_updated')],
                     [:error_explanation, ['1 error prohibited this admin from being saved:', 'Contact name can\'t be blank']]])
    expect_edit_page(page, Admin.find_by(id: me.id),
                     { contact_name: '' })
  end

  it 'validation Contact phone' do
    me = FactoryBot.create(:admin)
    login_as(me, scope: :admin)
    visit edit_admin_path(me)
    fill_in(I18n.t('activerecord.attributes.admin.contact_phone'), with: '')
    click_button('update')

    expect_edit_page(page, Admin.find_by(id: me.id), { contact_phone: '' })
    expect_messages([[:flash_alert, I18n.t('messages.flash.alert.admin.not_updated')],
                     [:error_explanation, ['1 error prohibited this admin from being saved:', 'Contact phone can\'t be blank']]])
  end

  it 'validation email presence' do
    me = FactoryBot.create(:admin)
    login_as(me, scope: :admin)
    visit edit_admin_path(me)
    fill_in(I18n.t('activerecord.attributes.admin.email'), with: '')
    click_button('update')

    expect_edit_page(page, Admin.find_by(id: me.id), { email: '' })
    expect_messages([[:flash_alert, I18n.t('messages.flash.alert.admin.not_updated')],
                     [:error_explanation, ['1 error prohibited this admin from being saved:', 'Email can\'t be blank']]])
  end

  it 'validation bad email' do
    me = FactoryBot.create(:admin)
    login_as(me, scope: :admin)
    visit edit_admin_path(me)
    fill_in(I18n.t('activerecord.attributes.admin.email'), with: '@ddd.com')
    click_button('update')

    expect_edit_page(page, Admin.find_by(id: me.id), { email: '@ddd.com' })
    expect_messages([[:flash_alert, I18n.t('messages.flash.alert.admin.not_updated')],
                     [:error_explanation, ['1 error prohibited this admin from being saved:', 'Email is invalid']]])
  end

  private

  def expect_edit_page(page, admin, values)
    account_name_value = values[:account_name].nil? ? admin.account_name : values[:account_name]
    name_value = values[:name].nil? ? admin.name : values[:name]
    contact_name_value = values[:contact_name].nil? ? admin.contact_name : values[:contact_name]
    contact_phone_value = values[:contact_phone].nil? ? admin.contact_phone : values[:contact_phone]
    email_value = values[:email].nil? ? admin.email : values[:email]
    expect(page).to have_selector('h2', count: 1, text: I18n.t('views.admins.heading.edit'))
    expect(page).to have_selector("input[type=text][id='admin_account_name'][value='#{account_name_value}']", count: 1)
    expect(page).to have_selector("input[type=text][id='admin_name'][value='#{name_value}']", count: 1)
    expect(page).to have_selector("input[type=text][id='admin_contact_name'][value='#{contact_name_value}']", count: 1)
    expect(page).to have_selector("input[type=text][id='admin_contact_phone'][value='#{contact_phone_value}']", count: 1)
    expect(page).to have_selector("input[type=email][id='admin_email'][value='#{email_value}']", count: 1)
    expect(page).to have_selector("input[type=submit][id='update'][value='Update']", count: 1)
  end
end
