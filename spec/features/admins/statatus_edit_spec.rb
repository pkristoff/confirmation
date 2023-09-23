# frozen_string_literal: true

Warden.test_mode!

describe 'Status edit', :devise do
  include Warden::Test::Helpers

  before do
    FactoryBot.create(:visitor)
    @admin = FactoryBot.create(:admin)
  end

  after do
    Warden.test_reset!
  end

  it 'update status - no errors' do
    status = FactoryBot.create(:status)
    login_as(@admin, scope: :admin)
    visit edit_status_path(status)

    expect_edit_page(page, { expected_name: status.name,
                             expected_description: status.description })
    click_button('Update Status')

    expect_show_page(page, status,
                     {
                       expected_messages: [[:flash_notice, I18n.t('messages.flash.alert.status.updated')],
                                           []],
                       expected_name: status.name,
                       expected_description: status.description
                     })
  end

  it 'update status - duplicating status error' do
    active_status = FactoryBot.create(:status)
    foo_status = FactoryBot.create(:status, name: 'foo', description: 'bar')
    login_as(@admin, scope: :admin)
    visit edit_status_path(foo_status)
    expect_edit_page(page, { expected_name: foo_status.name,
                             expected_description: foo_status.description })

    fill_in('status[name]', with: active_status.name)
    click_button('Update Status')

    expect_edit_page(page,
                     {
                       expected_messages: [[:flash_alert, I18n.t('messages.flash.alert.status.not_updated')],
                                           [:error_explanation,
                                            ['1 error prohibited this status from being saved:',
                                             'Name has already been taken']]],
                       expected_name: active_status.name,
                       expected_description: foo_status.description
                     })
  end

  private

  def expect_edit_page(page, values)
    is_new_record = false
    puts page.html
    expected_messages = values[:expected_messages]
    expect_messages(expected_messages) unless expected_messages.nil?
    expected_name = values[:expected_name].nil? ? '' : values[:expected_name]
    expected_description = values[:expected_description].nil? ? '' : values[:expected_description]
    expect(page).to have_selector("h2[id='header']", text: I18n.t('views.statuses.heading.edit'))

    expect(page).to have_css "input[type=text][name='status[name]'][value='#{expected_name}']"

    expect(page).to have_field('status[description]',
                               type: 'textarea', text: expected_description)

    expect(page).to have_button(I18n.t((is_new_record ? 'helpers.submit.create' : 'helpers.submit.update'),
                                       model: I18n.t('activerecord.models.status')), count: 1, disabled: false)
  end

  def expect_show_page(page, status, values)
    is_new_record = false
    puts page.html
    expected_messages = values[:expected_messages]
    expect_messages(expected_messages) unless expected_messages.nil?
    expected_name = values[:expected_name].nil? ? '' : values[:expected_name]
    expected_description = values[:expected_description].nil? ? '' : values[:expected_description]
    # expect_messages([[:flash_notice, I18n.t('messages.flash.notice.common.updated')]])
    # check to see if gone to admin sign in page
    expect(page).to have_selector("h2[id='header']", text: I18n.t('views.statuses.heading.show'))

    expect(page).to have_css "input[type=text][name='status[name]'][disabled='disabled'][value='#{expected_name}']"
    # expect(page).to have_field('status[name]',
    #                                type: 'text', text: expected_name)
    expect(page).to have_field('status[description]',
                               type: 'textarea', text: expected_description, disabled: true)

    expect(page).not_to have_button(I18n.t((is_new_record ? 'helpers.submit.create' : 'helpers.submit.update'),
                                           model: I18n.t('activerecord.models.status')), count: 1, disabled: false)
    expect(page).to have_link('Edit', href: edit_status_path(status))
    expect(page).to have_link('Back', href: '/statuses')
  end
end
