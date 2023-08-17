# frozen_string_literal: true

Warden.test_mode!

# Feature: Admin edit
#   As a admin
#   I want to edit my admin profile
#   So I can change my email address
describe 'Admin sign up', :devise do
  include Warden::Test::Helpers

  before do
    FactoryBot.create(:visitor)
  end

  after do
    Warden.test_reset!
  end

  # it: only an admin can sign up another admin
  #   Given no one is signed in
  #   When i click sign up
  #   Then I am blocked from creating an admin
  it 'attempt to sign up a new admin with no one signed in' do
    # referer = new_admin_path
    # Capybara.current_session.driver.header 'Referer', referer
    visit new_admin_path # click Sign up admin

    # check to see if gone to admin sign in page
    expect(page).to have_selector('h2', text: I18n.t('views.admins.sign_in'))
    expect_message(:flash_alert, I18n.t('devise.failure.unauthenticated'))
  end

  # it: only an admin can sign up another admin 2
  #   Given candidate is signed in (not admin)
  #   When i click sign up
  #   Then I am blocked from creating an admin
  it 'only an admin can sign up another admin' do
    candidate = FactoryBot.create(:candidate)
    login_as(candidate, scope: :candidate)
    referer = '/admins/sign_in'
    Capybara.current_session.driver.header 'Referer', referer
    visit new_admin_path # click Sign up admin
    expect(page).to have_selector('h2', text: I18n.t('views.admins.sign_in'))
    expect_message(:flash_alert, I18n.t('devise.failure.unauthenticated'))
    expect(page).to have_current_path(referer)
  end

  describe 'Sign in admin' do
    before do
      admin = FactoryBot.create(:admin)
      signin_admin(admin.account_name, admin.password)
    end

    # it: Admin  can sign up another admin
    #   Given I am signed in as admin
    #   When i click admin sign up
    #   Then I am not blocked because i am logged in
    it 'admin can sign up another admin' do
      visit new_admin_path(Admin.new)
      expect_new_admin(page)

      fill_in_legal_values

      click_button(I18n.t('views.admins.button.create'))

      expect_messages([[:flash_notice, I18n.t('views.candidates.created',
                                              account: 'Admin_1',
                                              name: 'Admin 1')]])
      expect(Admin.count).to be(2)
      expect_edit_admin(page, Admin.find_by(account_name: 'Admin_1'), {})
    end

    it 'admin can not create a new admin with out ny fiels filled in' do
      visit new_admin_path(Admin.new)
      expect_new_admin(page)

      click_button(I18n.t('views.admins.button.create'))

      expect_messages([[:flash_alert, I18n.t('views.common.save_failed',
                                             failee: 'Admin_1')],
                       [:error_explanation, ['4 errors prohibited this admin from being saved:',
                                             'Email can\'t be blank', 'Password can\'t be blank',
                                             'Contact name can\'t be blank',
                                             'Contact phone can\'t be blank']]])
      expect(Admin.count).to be(1)

      expect_new_admin(page, { account_name: 'Admin_1',
                               name: 'Admin 1' })
    end

    it 'admin can not create a new admin with out a contact name' do
      visit new_admin_path(Admin.new)
      expect_new_admin(page)

      fill_in_legal_values
      fill_in(I18n.t('activerecord.attributes.admin.contact_name'), with: '')

      click_button(I18n.t('views.admins.button.create'))

      expect_messages([[:flash_alert, I18n.t('views.common.save_failed',
                                             failee: 'Admin_1')],
                       [:error_explanation, ['1 error prohibited this admin from being saved:',
                                             'Contact name can\'t be blank']]])
      expect(Admin.count).to be(1)

      expect_new_admin(page, { account_name: 'Admin_1',
                               name: 'Admin 1' })
    end

    it 'admin can not create a new admin with out an email' do
      visit new_admin_path(Admin.new)
      expect_new_admin(page)

      fill_in_legal_values
      fill_in(I18n.t('activerecord.attributes.admin.email'), with: '')

      click_button(I18n.t('views.admins.button.create'))

      expect_messages([[:flash_alert, I18n.t('views.common.save_failed',
                                             failee: 'Admin_1')],
                       [:error_explanation, ['1 error prohibited this admin from being saved:',
                                             'Email can\'t be blank']]])
      expect(Admin.count).to be(1)

      expect_new_admin(page, { account_name: 'Admin_1',
                               name: 'Admin 1' })
    end

    it 'admin can not create a new admin with out a valid email' do
      visit new_admin_path(Admin.new)
      expect_new_admin(page)

      fill_in_legal_values
      fill_in(I18n.t('activerecord.attributes.admin.email'), with: 'paulfoo.com')

      click_button(I18n.t('views.admins.button.create'))

      expect_messages([[:flash_alert, I18n.t('views.common.save_failed',
                                             failee: 'Admin_1')],
                       [:error_explanation, ['1 error prohibited this admin from being saved:',
                                             'Email is invalid']]])
      expect(Admin.count).to be(1)

      expect_new_admin(page, { account_name: 'Admin_1',
                               name: 'Admin 1' })
    end

    it 'admin can not create a new admin with out a contact phone' do
      visit new_admin_path(Admin.new)
      expect_new_admin(page)

      fill_in_legal_values
      fill_in(I18n.t('activerecord.attributes.admin.contact_phone'), with: '')

      click_button(I18n.t('views.admins.button.create'))

      expect_messages([[:flash_alert, I18n.t('views.common.save_failed',
                                             failee: 'Admin_1')],
                       [:error_explanation, ['1 error prohibited this admin from being saved:',
                                             'Contact phone can\'t be blank']]])
      expect(Admin.count).to be(1)

      expect_new_admin(page, { account_name: 'Admin_1',
                               name: 'Admin 1' })
    end

    it 'admin can not create a new admin with out an password' do
      visit new_admin_path(Admin.new)
      expect_new_admin(page)

      fill_in_legal_values
      fill_in(I18n.t('activerecord.attributes.admin.password'), with: '')

      click_button(I18n.t('views.admins.button.create'))

      expect_messages([[:flash_alert, I18n.t('views.common.save_failed',
                                             failee: 'Admin_1')],
                       [:error_explanation, ['2 errors prohibited this admin from being saved:',
                                             'Password can\'t be blank',
                                             'Confirmation password doesn\'t match Password']]])
      expect(Admin.count).to be(1)

      expect_new_admin(page, { account_name: 'Admin_1',
                               name: 'Admin 1' })
    end

    private

    def fill_in_legal_values
      fill_in(I18n.t('activerecord.attributes.admin.contact_name'), with: 'george smith')
      fill_in(I18n.t('activerecord.attributes.admin.email'), with: 'retail@ddd.com')
      fill_in(I18n.t('activerecord.attributes.admin.contact_phone'), with: '919-919-9999')
      fill_in(I18n.t('activerecord.attributes.admin.password'), with: 'abcdefgh')
      fill_in(I18n.t('activerecord.attributes.admin.password_confirmation'), with: 'abcdefgh')
    end

    def expect_new_admin(page, values = {})
      account_name_value = values[:account_name].nil? ? 'Admin' : values[:account_name]
      # name_value = values[:name].nil? ? '' : values[:name]
      contact_name_value = values[:contact_name].nil? ? '' : values[:contact_name]
      contact_phone_value = values[:contact_phone].nil? ? '' : values[:contact_phone]
      email_value = values[:email].nil? ? '' : values[:email]
      # header
      expect(page).to have_selector('h2', text: I18n.t('views.admins.heading.new'))
      admin_name_selector = "input[type=text][id='admin_account_name'][value='#{account_name_value}'][disabled='disabled']"
      expect(page).to have_selector(admin_name_selector, count: 1)
      expect(page).to have_field(I18n.t('activerecord.attributes.admin.name'), count: 1, disabled: false)
      expect(page).to have_field(I18n.t('activerecord.attributes.admin.contact_name'),
                                 text: contact_name_value, count: 1, disabled: false)
      expect(page).to have_field(I18n.t('activerecord.attributes.admin.email'), text: email_value, count: 1, disabled: false)
      expect(page).to have_field(I18n.t('activerecord.attributes.admin.contact_phone'),
                                 text: contact_phone_value, count: 1, disabled: false)
      expect(page).to have_field(I18n.t('activerecord.attributes.admin.password'), text: '', count: 1, disabled: false)
      expect(page).to have_field(I18n.t('activerecord.attributes.admin.password_confirmation'),
                                 text: '', count: 1, disabled: false)

      expect(page).to have_button(I18n.t('views.admins.button.create'), count: 1, disabled: false)
    end

    def expect_edit_admin(page, admin, values)
      account_name_value = values[:account_name].nil? ? admin.account_name : values[:account_name]
      name_value = values[:name].nil? ? admin.name : values[:name]
      contact_name_value = values[:contact_name].nil? ? admin.contact_name : values[:contact_name]
      contact_phone_value = values[:contact_phone].nil? ? admin.contact_phone : values[:contact_phone]
      email_value = values[:email].nil? ? admin.email : values[:email]
      # header
      expect(page).to have_selector('h2', count: 1, text: I18n.t('views.admins.heading.edit'))
      expect(page).to have_selector("input[type=text][id='admin_account_name'][value='#{account_name_value}']", count: 1)
      expect(page).to have_selector("input[type=text][id='admin_name'][value='#{name_value}']", count: 1)
      expect(page).to have_selector("input[type=text][id='admin_contact_name'][value='#{contact_name_value}']", count: 1)
      expect(page).to have_selector("input[type=text][id='admin_contact_phone'][value='#{contact_phone_value}']", count: 1)
      expect(page).to have_selector("input[type=email][id='admin_email'][value='#{email_value}']", count: 1)
      expect(page).to have_selector("input[type=submit][id='update'][value='Update']", count: 1)

      expect(page).to have_button(I18n.t('views.common.update'), count: 1, disabled: false)
    end
  end
end
