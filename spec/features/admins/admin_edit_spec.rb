# frozen_string_literal: true

Warden.test_mode!

# Feature: Admin edit
#   As a admin
#   I want to edit my admin profile
#   So I can change my email address
feature 'Admin edit', :devise do
  include Warden::Test::Helpers

  after(:each) do
    Warden.test_reset!
  end

  # Scenario: Admin changes email address
  #   Given I am signed in
  #   When I change my email address
  #   Then I see an account updated message
  scenario 'admin changes email address' do
    admin = FactoryBot.create(:admin)
    login_as(admin, scope: :admin)
    visit edit_admin_registration_path(admin)
    fill_in I18n.t('views.admins.email'), with: 'newemail@example.com'
    fill_in I18n.t('views.admins.current_password'), with: admin.password
    click_button I18n.t('views.common.update')
    txts = [I18n.t('devise.registrations.updated'), I18n.t('devise.registrations.update_needs_confirmation')]
    expect_message(:flash_notice, /.*#{txts[0]}.*|.*#{txts[1]}.*/)
  end

  # Scenario: Admin cannot edit another admin's profile
  #   Given I am signed in
  #   When I try to edit another admin's profile
  #   Then I see my own 'edit profile' page

  scenario 'edit myself' do
    me = FactoryBot.create(:admin)
    login_as(me, scope: :admin)
    visit edit_admin_registration_path(me)
    fill_in(I18n.t('label.admin.contact_name'), with: 'Paul')
    fill_in(I18n.t('label.admin.contact_phone'), with: '919-555-5555')
    fill_in(I18n.t('views.admins.email'), with: 'xxx@yyy.com')
    click_button('update')

    expect(page).to have_selector('p', text: "#{I18n.t('label.admin.contact_name')}: Paul")
  end

  scenario 'validation Contact name' do
    me = FactoryBot.create(:admin)
    login_as(me, scope: :admin)
    visit edit_admin_registration_path(me)
    fill_in(I18n.t('label.admin.contact_name'), with: '')
    click_button('update')

    expect_messages([[:error_explanation, ['1 error prohibited this admin from being saved:', 'Contact name can\'t be blank']]])
  end

  scenario 'validation Contact phone' do
    me = FactoryBot.create(:admin)
    login_as(me, scope: :admin)
    visit edit_admin_registration_path(me)
    fill_in(I18n.t('label.admin.contact_phone'), with: '')
    click_button('update')

    expect_messages([[:error_explanation, ['1 error prohibited this admin from being saved:', 'Contact phone can\'t be blank']]])
  end

  scenario 'validation email presence' do
    me = FactoryBot.create(:admin)
    login_as(me, scope: :admin)
    visit edit_admin_registration_path(me)
    fill_in(I18n.t('views.admins.email'), with: '')
    click_button('update')

    expect_messages([[:error_explanation, ['1 error prohibited this admin from being saved:', 'Email can\'t be blank']]])
  end

  scenario 'validation bad email' do
    me = FactoryBot.create(:admin)
    login_as(me, scope: :admin)
    visit edit_admin_registration_path(me)
    fill_in(I18n.t('views.admins.email'), with: '@ddd.com')
    click_button('update')

    expect_messages([[:error_explanation, ['1 error prohibited this admin from being saved:', 'Email is invalid']]])
  end
end
