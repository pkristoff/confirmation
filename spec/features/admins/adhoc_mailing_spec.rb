# frozen_string_literal: true

Warden.test_mode!

describe 'Admin monthly mass mailing', :devise do
  include ViewsHelpers
  include Warden::Test::Helpers

  before do
    FactoryBot.create(:visitor)
  end

  after do
    Warden.test_reset!
  end

  it 'admin has to select candidate' do
    admin = FactoryBot.create(:admin)
    login_as(admin, scope: :admin)

    visit adhoc_mailing_path

    fill_in I18n.t('email.subject_label'), with: 'The subject'
    fill_in I18n.t('email.body_label'), with: 'The body'
    attach_file(I18n.t('label.mail.attach_file'), 'spec/fixtures/files/Initial candidates update.xlsx')

    click_button('top-update')

    expect_message(:flash_alert, I18n.t('messages.no_candidate_selected'))
    have_css('form[enctype="multipart/form-data"]')
    expect(page).to have_field(I18n.t('email.subject_label'), with: 'The subject')
    expect(page).to have_field(I18n.t('email.body_label'), with: 'The body')

    expect_mail_attachment_upload
  end

  it 'admin can send email to multiple candidates' do
    candidate1 = create_candidate('Vicki', 'Anne', 'Kristoff')
    candidate2 = create_candidate('Paul', 'Richard', 'Kristoff')

    admin = FactoryBot.create(:admin)
    AppFactory.add_confirmation_events

    login_as(admin, scope: :admin)

    visit adhoc_mailing_path

    fill_in I18n.t('email.subject_label'), with: 'The subject'
    fill_in I18n.t('email.body_label'), with: 'The body'

    check("candidate_candidate_ids_#{candidate1.id}")
    check("candidate_candidate_ids_#{candidate2.id}")
    click_button('top-update')

    expect_message(:flash_notice, I18n.t('messages.adhoc_mailing_progress'))
    expect(page).to have_field(I18n.t('email.subject_label'), with: 'The subject')
    expect(page).to have_field(I18n.t('email.body_label'), with: 'The body')
  end

  it 'admin can send test adhoc email to self' do
    candidate1 = create_candidate('Vicki', 'Anne', 'Kristoff')

    admin = FactoryBot.create(:admin)
    AppFactory.add_confirmation_events

    login_as(admin, scope: :admin)

    visit adhoc_mailing_path

    fill_in I18n.t('email.subject_label'), with: 'The subject'
    fill_in I18n.t('email.body_label'), with: 'The body'
    check("candidate_candidate_ids_#{candidate1.id}")
    click_button('top-test')

    expect_message(:flash_notice, I18n.t('messages.adhoc_mailing_test_sent'))
    expect(page).to have_field(I18n.t('email.subject_label'), with: 'The subject')
    expect(page).to have_field(I18n.t('email.body_label'), with: 'The body')
  end

  it 'admin has to select candidate for adhoc test' do
    admin = FactoryBot.create(:admin)
    login_as(admin, scope: :admin)

    visit adhoc_mailing_path

    fill_in I18n.t('email.subject_label'), with: 'The subject'
    fill_in I18n.t('email.body_label'), with: 'The body'

    click_button('top-test')

    expect_message(:flash_alert, I18n.t('messages.no_candidate_selected'))
    expect(page).to have_field(I18n.t('email.subject_label'), with: 'The subject')
    expect(page).to have_field(I18n.t('email.body_label'), with: 'The body')
  end

  it 'admin has to select candidate second time through for adhoc test' do
    candidate1 = create_candidate('Vicki', 'Anne', 'Kristoff')

    admin = FactoryBot.create(:admin)
    AppFactory.add_confirmation_events

    login_as(admin, scope: :admin)

    visit adhoc_mailing_path

    fill_in I18n.t('email.subject_label'), with: 'The subject'
    fill_in I18n.t('email.body_label'), with: 'The body'
    check("candidate_candidate_ids_#{candidate1.id}")
    click_button('top-test')

    expect_message(:flash_notice, I18n.t('messages.adhoc_mailing_test_sent'))
    expect(page).to have_field(I18n.t('email.subject_label'), with: 'The subject')
    expect(page).to have_field(I18n.t('email.body_label'), with: 'The body')

    # no candidate is selected

    click_button('top-test')

    expect_message(:flash_alert, I18n.t('messages.no_candidate_selected'))
    expect(page).to have_field(I18n.t('email.subject_label'), with: 'The subject')
    expect(page).to have_field(I18n.t('email.body_label'), with: 'The body')
  end
end
