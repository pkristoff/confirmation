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
    visit new_admin_registration_path # click Sign up admin

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
    visit new_admin_registration_path # click Sign up admin
    expect(page).to have_selector('h2', text: I18n.t('views.admins.sign_in'))
    expect_message(:flash_alert, I18n.t('messages.admin_login_needed',
                                        message: I18n.t('messages.another_admin')))
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
      visit new_admin_registration_path(Admin.new)
      expect_new_admin(page, Admin.new, {})

      fill_in(I18n.t('activerecord.attributes.admin.contact_name'), with: 'george smith')
      fill_in(I18n.t('activerecord.attributes.admin.email'), with: 'paul@ddd.com')
      fill_in(I18n.t('activerecord.attributes.admin.contact_phone'), with: '919-919-9999')
      fill_in(I18n.t('activerecord.attributes.admin.password'), with: 'abcdefgh')
      fill_in(I18n.t('activerecord.attributes.admin.password_confirmation'), with: 'abcdefgh')

      click_button(I18n.t('views.admins.button.create'))

      expect_messages([[:flash_notice, I18n.t('views.candidates.created',
                                              account: 'Admin_1',
                                              name: 'Admin 1')]])
      expect(Admin.count).to be(2)
      expect_edit_admin(page, Admin.find_by(account_name: 'Admin_1'), {})
    end

    it 'admin can not create a new admin with out all the info' do
      visit new_admin_registration_path(Admin.new)
      expect_new_admin(page, Admin.new, {})

      click_button(I18n.t('views.admins.button.create'))

      expect_messages([[:flash_alert, I18n.t('views.common.save_failed',
                                             failee: 'Admin_1')],
                       [:error_explanation, ['4 errors prohibited this admin from being saved:',
                                             'Email can\'t be blank', 'Password can\'t be blank',
                                             'Contact name can\'t be blank',
                                             'Contact phone can\'t be blank']]])
      expect(Admin.count).to be(1)
      puts page.html
      expect_new_admin(page, Admin.new, { account_name: 'Admin_1',
                                          name: 'Admin 1' })
    end

    private

    def expect_new_admin(page, new_admin, values = {})
      account_name_value = values[:account_name].nil? ? new_admin.account_name : values[:account_name]
      name_value = values[:name].nil? ? new_admin.name : values[:name]
      contact_name_value = values[:contact_name].nil? ? new_admin.contact_name : values[:contact_name]
      contact_phone_value = values[:contact_phone].nil? ? new_admin.contact_phone : values[:contact_phone]
      email_value = values[:email].nil? ? new_admin.email : values[:email]
      # header
      expect(page).to have_selector('h2', text: I18n.t('views.admins.heading.new'))
      # expect(page).to have_selector('form[id=new_admin][action="/admins"]', count: 1)
      admin_name_selector = "input[type=text][id='admin_account_name'][value='#{account_name_value}'][disabled='disabled']"
      expect(page).to have_selector(admin_name_selector, count: 1)
      expect(page).to have_selector("input[type=text][id='admin_name'][value='#{name_value}'][disabled='disabled']",
                                    count: 1)
      # expect(page).to have_field(I18n.t('activerecord.attributes.admin.account_name'),
      #                            text: account_name_value, count: 1, disabled: true)
      # expect(page).to have_field(I18n.t('activerecord.attributes.admin.name'), text: name_value, count: 1, disabled: true)
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

    # it: Visitor cannot sign up - ony admin can create a new candidate
    #   Given I am not signed in
    #   When I sign up with a valid email address and password
    #   Then I see a successful sign up message
    # it 'visitor can sign up with valid email address and password' do
    #   visit new_admin_registration_path
    #   expect(page).to have_selector('p', count: 3)
    #   expect(page).to have_selector('h3', text: 'Admin')
    #   expect(page).to have_selector('p', text: 'Name: Admin Candidate')
    #   expect(page).to have_selector('p', text: 'Email: test@example.com')
    # sign_up_admin_with('test1@example.com', 'please123', 'please123')
    # txts = [I18n.t('devise.registrations.signed_up'),
    #         I18n.t('devise.registrations.signed_up_but_unconfirmed')]
    # expect_message :flash_notice, /.*#{txts[0]}.*|.*#{txts[1]}.*/
    # end
    # it: Visitor cannot sign up with invalid email address
    #   Given I am not signed in
    #   When I sign up with an invalid email address
    #   Then I see an invalid email message
    # it 'visitor cannot sign up with invalid email address' do
    #   sign_up_admin_with('bogus', 'please123', 'please123')
    #   expect_message :error_explanation, 'Email is invalid'
    # end

    # it: Visitor cannot sign up without password
    #   Given I am not signed in
    #   When I sign up without a password
    #   Then I see a missing password message
    # it 'visitor cannot sign up without password' do
    #   sign_up_admin_with('test1@example.com', '', '')
    #   expect_message :error_explanation, 'Password can\'t be blank'
    # end

    # it: Visitor cannot sign up with a short password
    #   Given I am not signed in
    #   When I sign up with a short password
    #   Then I see a 'too short password' message
    # it 'visitor cannot sign up with a short password' do
    #   sign_up_admin_with('test1@example.com', 'please', 'please')
    #   expect_message :error_explanation, 'Password is too short'
    # end

    # it: Visitor cannot sign up without password confirmation
    #   Given I am not signed in
    #   When I sign up without a password confirmation
    #   Then I see a missing password confirmation message
    # it 'visitor cannot sign up without password confirmation' do
    #   sign_up_admin_with('test1@example.com', 'please123', '')
    #   expect_message :error_explanation, 'Password confirmation doesn\'t match'
    # end
  end
end
