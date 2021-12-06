# frozen_string_literal: true

Warden.test_mode!

# rubocop:disable Layout/LineLength
CONTACT_INIT_VALUE = '<a href="mailto:stmm.confirmation@kristoffs.com?subject=Help" target="_top">Contact Admin via email stmm.confirmation@kristoffs.com</a>'
CONTACT_CHANGED_VALUE = '<a href="mailto:stmm.confirmation@kristoffs.com?subject=Help" id="foo" style="bold" target="_top">Contact Admin via email stmm.confirmation@kristoffs.com</a>'
# rubocop:enable Layout/LineLength

HOME_PARISH_INIT_VALUE = 'St. Mary Magdalene'
HOME_INIT_VALUE = '<div><p>Welcome</p></div>'
HOME_PARISH_CHANGED_VALUE = 'St. Michaels'
HOME_CHANGED_VALUE = '<div id="foo">ccc yyy</div>'
ABOUT_INIT_VALUE = '<code>About</code>'
ABOUT_CHANGED_VALUE = '<div id="bar">ddd zzz</div>'

feature 'admins/show_visitor.html.erb' do
  include Warden::Test::Helpers

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

    expect_show_visitor({ home_parish: HOME_PARISH_INIT_VALUE,
                          home: HOME_INIT_VALUE, about: ABOUT_INIT_VALUE, contact: CONTACT_INIT_VALUE,
                          street1: '', street2: '', city: '', state: '', zip_code: '' })
  end

  scenario 'edit the visitor home page change home parish' do
    visit show_visitor_path
    expect_show_visitor({ home_parish: HOME_PARISH_INIT_VALUE,
                          home: HOME_INIT_VALUE, about: ABOUT_INIT_VALUE, concact: CONTACT_INIT_VALUE,
                          street1: '', street2: '', city: '', state: '', zip_code: '',
                          expected_messages: [] })

    fill_in(I18n.t('label.visitor.home_parish'), with: HOME_PARISH_CHANGED_VALUE)
    click_button('top-update-home-parish')

    expect_show_visitor({ home_parish: HOME_PARISH_CHANGED_VALUE,
                          home: HOME_INIT_VALUE, about: ABOUT_INIT_VALUE, concact: CONTACT_INIT_VALUE,
                          street1: '', street2: '', city: '', state: '', zip_code: '',
                          expected_messages: [[:flash_notice, I18n.t('messages.home_parish_updated')]] })
  end

  scenario 'change home parish address' do
    visit show_visitor_path
    expect_show_visitor({ home_parish: HOME_PARISH_INIT_VALUE,
                          home: HOME_INIT_VALUE, about: ABOUT_INIT_VALUE, concact: CONTACT_INIT_VALUE,
                          street1: '', street2: '', city: '', state: '', zip_code: '',
                          expected_messages: [] })

    street1_change = '1212 victory way'
    street2_change = 'apt 2'
    city_change = 'georgeville'
    state_change = 'WY'
    zip_code_change = '95036'

    fill_in(I18n.t('label.visitor.home_parish_address.street_1'), with: street1_change)
    fill_in(I18n.t('label.visitor.home_parish_address.street_2'), with: street2_change)
    fill_in(I18n.t('label.visitor.home_parish_address.city'), with: city_change)
    fill_in(I18n.t('label.visitor.home_parish_address.state'), with: state_change)
    fill_in(I18n.t('label.visitor.home_parish_address.zip_code'), with: zip_code_change)
    click_button('top-update-home-parish')

    puts page.html
    expect_show_visitor({ home_parish: HOME_PARISH_INIT_VALUE,
                          home: HOME_INIT_VALUE, about: ABOUT_INIT_VALUE, concact: CONTACT_INIT_VALUE,
                          street1: street1_change, street2: street2_change, city: city_change,
                          state: state_change, zip_code: zip_code_change,
                          expected_messages: [[:flash_notice, I18n.t('messages.home_parish_updated')]] })
  end

  scenario 'edit the visitor home page change home value' do
    visit show_visitor_path
    expect_show_visitor({ home_parish: HOME_PARISH_INIT_VALUE,
                          home: HOME_INIT_VALUE, about: ABOUT_INIT_VALUE, concact: CONTACT_INIT_VALUE,
                          street1: '', street2: '', city: '', state: '', zip_code: '',
                          expected_messages: [] })

    fill_in(I18n.t('label.visitor.home'), with: HOME_CHANGED_VALUE)
    click_button('top-update-home')

    expect_show_visitor({ home_parish: HOME_PARISH_INIT_VALUE,
                          home: HOME_CHANGED_VALUE, about: ABOUT_INIT_VALUE, contact: CONTACT_INIT_VALUE,
                          street1: '', street2: '', city: '', state: '', zip_code: '',
                          expected_messages: [[:flash_notice, I18n.t('messages.home_updated')]] })
  end

  scenario 'edit the visitor home page change about value' do
    visit show_visitor_path
    expect_show_visitor({ home_parish: HOME_PARISH_INIT_VALUE,
                          home: HOME_INIT_VALUE, about: ABOUT_INIT_VALUE, concact: CONTACT_INIT_VALUE,
                          street1: '', street2: '', city: '', state: '', zip_code: '',
                          expected_messages: [] })

    fill_in(I18n.t('label.visitor.about'), with: ABOUT_CHANGED_VALUE)
    click_button('top-update-about')

    expect_show_visitor({ home_parish: HOME_PARISH_INIT_VALUE,
                          home: HOME_INIT_VALUE, about: ABOUT_CHANGED_VALUE, contact: CONTACT_INIT_VALUE,
                          street1: '', street2: '', city: '', state: '', zip_code: '',
                          expected_messages: [[:flash_notice, I18n.t('messages.about_updated')]] })
  end

  scenario 'edit the visitor home page change contact value' do
    visit show_visitor_path
    expect_show_visitor({ home_parish: HOME_PARISH_INIT_VALUE,
                          home: HOME_INIT_VALUE, about: ABOUT_INIT_VALUE, concact: CONTACT_INIT_VALUE,
                          street1: '', street2: '', city: '', state: '', zip_code: '',
                          expected_messages: [] })

    fill_in(I18n.t('label.visitor.contact_information'), with: CONTACT_CHANGED_VALUE)
    click_button('top-update-contact')

    expect_show_visitor({ home_parish: HOME_PARISH_INIT_VALUE,
                          home: HOME_INIT_VALUE, about: ABOUT_INIT_VALUE, contact: CONTACT_CHANGED_VALUE,
                          street1: '', street2: '', city: '', state: '', zip_code: '',
                          expected_messages: [[:flash_notice, I18n.t('messages.contact_information_updated')]] })
  end

  private

  def expect_show_visitor(values = {})
    expect_messages(values[:expected_messages], page) if values[:expected_messages].present?

    expect(page).to have_css("section[id='home_parish']")
    expect(page).to have_css "section[id='home_parish'] form[action='/update_visitor/#{@visitor.id}']"
    expect(page).to have_field(I18n.t('label.visitor.home_parish'), with: values[:home_parish])

    expect_home_parish_address(values)

    i18n = I18n.t('views.common.update_home_parish')
    loc = "section[id='home_parish'] input[id='top-update-home-parish'][type='submit'][value='#{i18n}']"
    expect(page).to have_css(loc)
    loc = "section[id='home_parish'] input[id='bottom-update-home-parish'][type='submit'][value='#{i18n}']"
    expect(page).to have_css(loc)

    expect(page).to have_css("section[id='home']")
    expect(page).to have_css "section[id='home'] form[action='/update_visitor/#{@visitor.id}']"
    expect(page).to have_field(I18n.t('label.visitor.home'), with: values[:home])
    #
    # d address fields
    #
    i18n = I18n.t('views.common.update_home')
    expect(page).to have_css("section[id='home'] input[id='top-update-home'][type='submit'][value='#{i18n}']")
    expect(page).to have_css("section[id='home'] input[id='bottom-update-home'][type='submit'][value='#{i18n}']")

    expect(page).to have_css("section[id='about']")
    expect(page).to have_css "section[id='about'] form[action='/update_visitor/#{@visitor.id}']"
    expect(page).to have_field(I18n.t('label.visitor.about'), with: values[:about])
    i18n = I18n.t('views.common.update_about')
    expect(page).to have_css("section[id='about'] input[id='top-update-about'][type='submit'][value='#{i18n}']")
    expected_msg = "section[id='about'] input[id='bottom-update-about'][type='submit'][value='#{i18n}']"
    expect(page).to have_css(expected_msg)

    expect(page).to have_css("section[id='contact']")
    expect(page).to have_css "section[id='contact'] form[action='/update_visitor/#{@visitor.id}']"

    expect(page).to have_selector('textarea[id=visitor_contact]', count: 1, text: values[:contact])
    # expect(page).to have_field(I18n.t('label.visitor.contact_information'), with: values[:contact])
    i18n = I18n.t('views.common.update_information_contact')
    expect(page).to have_css("section[id='contact'] input[id='top-update-contact'][type='submit'][value='#{i18n}']")
    expected_msg = "section[id='contact'] input[id='bottom-update-contact'][type='submit'][value='#{i18n}']"
    expect(page).to have_css(expected_msg)

    expect(page).to have_css('section', count: 4)
  end

  def expect_home_parish_address(values)
    expect(Address.count).to eq(1)
    ExpectFields.expect_have_field_text(
      page,
      I18n.t('label.visitor.home_parish_address.street_1'),
      'visitor_home_parish_address_attributes_street_1',
      values[:street1],
      false,
      true,
      ''
    )
    ExpectFields.expect_have_field_text(
      page,
      I18n.t('label.visitor.home_parish_address.street_2'),
      'visitor_home_parish_address_attributes_street_2',
      values[:street2],
      false,
      true,
      ''
    )
    ExpectFields.expect_have_field_text(
      page,
      I18n.t('label.visitor.home_parish_address.city'),
      'visitor_home_parish_address_attributes_city',
      values[:city],
      false,
      true,
      ''
    )
    ExpectFields.expect_have_field_text(
      page,
      I18n.t('label.visitor.home_parish_address.state'),
      'visitor_home_parish_address_attributes_state',
      values[:state],
      false,
      true,
      ''
    )
    ExpectFields.expect_have_field_text(
      page,
      I18n.t('label.visitor.home_parish_address.zip_code'),
      'visitor_home_parish_address_attributes_zip_code',
      values[:zip_code],
      false,
      true,
      ''
    )
  end
end
