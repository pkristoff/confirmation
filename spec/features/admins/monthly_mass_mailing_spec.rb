# frozen_string_literal: true

Warden.test_mode!

feature 'Admin monthly mass mailing', :devise do
  include ViewsHelpers
  include Warden::Test::Helpers

  after(:each) do
    Warden.test_reset!
  end

  scenario 'admin has to select candidate before sending monthly email' do
    admin = FactoryBot.create(:admin)
    login_as(admin, scope: :admin)
    visit monthly_mass_mailing_path

    fill_in I18n.t('email.subject_label'), with: 'The subject'
    fill_in I18n.t('email.pre_late_input_label'), with: 'The pre_late_input'
    fill_in I18n.t('email.pre_coming_due_input_label'), with: 'The pre_coming_text'
    fill_in I18n.t('email.completed_awaiting_input_label'), with: 'The completed_awaiting_text'
    fill_in I18n.t('email.completed_input_label'), with: 'The completed_text'
    fill_in I18n.t('email.closing_input_label'), with: 'The closing_text'
    fill_in I18n.t('email.salutation_input_label'), with: 'The salutation_text'
    fill_in I18n.t('email.from_input_label'), with: 'The from_text'
    attach_file(I18n.t('label.mail.attach_file'), 'spec/fixtures/Initial candidates update.xlsx')

    click_button('top-update')

    expect_monthly_mass_mailing_form(expect_messages: [[:flash_alert, I18n.t('messages.no_candidate_selected')]],
                                     subject: 'The subject',
                                     pre_late_input: 'The pre_late_input',
                                     pre_coming_input: 'The pre_coming_text',
                                     awaiting_approval: 'The completed_awaiting_text',
                                     completed_events: 'The completed_text',
                                     closing_paragraph: 'The closing_text',
                                     salutation_input: 'The salutation_text',
                                     from_input: 'The from_text')

    expect_mail_attadchment_upload
  end

  scenario 'admin can send email to multiple candidates' do
    candidate1 = create_candidate('Vicki', 'Anne', 'Kristoff')
    candidate2 = create_candidate('Paul', 'Richard', 'Kristoff')

    admin = FactoryBot.create(:admin)
    AppFactory.add_confirmation_events

    login_as(admin, scope: :admin)

    visit monthly_mass_mailing_path

    fill_in I18n.t('email.subject_label'), with: 'The subject'
    fill_in I18n.t('email.pre_late_input_label'), with: 'The pre_late_input'
    fill_in I18n.t('email.pre_coming_due_input_label'), with: 'The pre_coming_input'
    fill_in I18n.t('email.completed_awaiting_input_label'), with: 'The completed_awaiting_input'
    fill_in I18n.t('email.completed_input_label'), with: 'The completed_input'
    fill_in I18n.t('email.closing_input_label'), with: 'The closing_input'
    fill_in I18n.t('email.salutation_input_label'), with: 'The salutation_input'
    fill_in I18n.t('email.from_input_label'), with: 'The from_input'

    check("candidate_candidate_ids_#{candidate1.id}")
    check("candidate_candidate_ids_#{candidate2.id}")

    click_button('top-update')

    expect_monthly_mass_mailing_form(expect_messages: [[:flash_notice, I18n.t('messages.monthly_mailing_progress')]],
                                     subject: 'The subject',
                                     pre_late_input: 'The pre_late_input',
                                     pre_coming_input: 'The pre_coming_input',
                                     awaiting_approval: 'The completed_awaiting_input',
                                     completed_events: 'The completed_input',
                                     closing_paragraph: 'The closing_input',
                                     salutation_input: 'The salutation_input',
                                     from_input: 'The from_input')
  end

  scenario 'admin can send email to multiple candidates with default values' do
    candidate1 = create_candidate('Vicki', 'Anne', 'Kristoff')
    candidate2 = create_candidate('Paul', 'Richard', 'Kristoff')

    admin = FactoryBot.create(:admin)
    AppFactory.add_confirmation_events

    login_as(admin, scope: :admin)

    visit monthly_mass_mailing_path

    check("candidate_candidate_ids_#{candidate1.id}")
    check("candidate_candidate_ids_#{candidate2.id}")

    click_button('top-update')

    # expect_message(:flash_notice, I18n.t('messages.monthly_mailing_progress'))
    expect_monthly_mass_mailing_form(expect_messages: [[:flash_notice, I18n.t('messages.monthly_mailing_progress')]])
  end

  scenario 'admin has to select candidate before sending test monthly email' do
    admin = FactoryBot.create(:admin)
    login_as(admin, scope: :admin)
    visit monthly_mass_mailing_path

    fill_in I18n.t('email.subject_label'), with: 'The subject'
    fill_in I18n.t('email.pre_late_input_label'), with: 'The pre_late_input'
    fill_in I18n.t('email.pre_coming_due_input_label'), with: 'The pre_coming_input'
    fill_in I18n.t('email.completed_awaiting_input_label'), with: 'The completed_awaiting_input'
    fill_in I18n.t('email.completed_input_label'), with: 'The completed_input'
    fill_in I18n.t('email.closing_input_label'), with: 'The closing_input'
    fill_in I18n.t('email.salutation_input_label'), with: 'The salutation_input'
    fill_in I18n.t('email.from_input_label'), with: 'The from_input'
    click_button('top-test')

    expect_monthly_mass_mailing_form(expect_messages: [[:flash_alert, I18n.t('messages.no_candidate_selected')]],
                                     subject: 'The subject',
                                     pre_late_input: 'The pre_late_input',
                                     pre_coming_input: 'The pre_coming_input',
                                     awaiting_approval: 'The completed_awaiting_input',
                                     completed_events: 'The completed_input',
                                     closing_paragraph: 'The closing_input',
                                     salutation_input: 'The salutation_input',
                                     from_input: 'The from_input')
  end

  scenario 'admin can send test email to a candidate with default values' do
    candidate1 = create_candidate('Vicki', 'Anne', 'Kristoff')

    admin = FactoryBot.create(:admin)
    AppFactory.add_confirmation_events

    login_as(admin, scope: :admin)

    visit monthly_mass_mailing_path

    check("candidate_candidate_ids_#{candidate1.id}")
    click_button('top-test')

    # expect_message(:flash_notice, I18n.t('messages.monthly_mailing_test_sent'))
    # expect_default_values
    expect_monthly_mass_mailing_form(expect_messages: [[:flash_notice, I18n.t('messages.monthly_mailing_test_sent')]])
  end

  scenario 'admin can send test email to a candidate' do
    candidate1 = create_candidate('Vicki', 'Anne', 'Kristoff')

    admin = FactoryBot.create(:admin)
    AppFactory.add_confirmation_events

    login_as(admin, scope: :admin)

    visit monthly_mass_mailing_path

    fill_in I18n.t('email.subject_label'), with: 'The subject'
    fill_in I18n.t('email.pre_late_input_label'), with: 'The pre_late_input'
    fill_in I18n.t('email.pre_coming_due_input_label'), with: 'The pre_coming_input'
    fill_in I18n.t('email.completed_awaiting_input_label'), with: 'The completed_awaiting_input'
    fill_in I18n.t('email.completed_input_label'), with: 'The completed_input'
    fill_in I18n.t('email.closing_input_label'), with: 'The closing_input'
    fill_in I18n.t('email.salutation_input_label'), with: 'The salutation_input'
    fill_in I18n.t('email.from_input_label'), with: 'The from_input'
    check("candidate_candidate_ids_#{candidate1.id}")
    click_button('top-test')

    expect_monthly_mass_mailing_form(expect_messages: [[:flash_notice, I18n.t('messages.monthly_mailing_test_sent')]],
                                     subject: 'The subject',
                                     pre_late_input: 'The pre_late_input',
                                     pre_coming_input: 'The pre_coming_input',
                                     awaiting_approval: 'The completed_awaiting_input',
                                     completed_events: 'The completed_input',
                                     closing_paragraph: 'The closing_input',
                                     salutation_input: 'The salutation_input',
                                     from_input: 'The from_input')
  end

  scenario 'admin has to select candidate second time through for monthly mass mailing test test' do
    candidate1 = create_candidate('Vicki', 'Anne', 'Kristoff')

    admin = FactoryBot.create(:admin)
    AppFactory.add_confirmation_events

    login_as(admin, scope: :admin)

    visit monthly_mass_mailing_path

    fill_in I18n.t('email.subject_label'), with: 'The subject'
    fill_in I18n.t('email.pre_late_input_label'), with: 'The pre_late_input'
    fill_in I18n.t('email.pre_coming_due_input_label'), with: 'The pre_coming_input'
    fill_in I18n.t('email.completed_awaiting_input_label'), with: 'The completed_awaiting_input'
    fill_in I18n.t('email.completed_input_label'), with: 'The completed_input'
    fill_in I18n.t('email.closing_input_label'), with: 'The closing_input'
    fill_in I18n.t('email.salutation_input_label'), with: 'The salutation_input'
    fill_in I18n.t('email.from_input_label'), with: 'The from_input'
    check("candidate_candidate_ids_#{candidate1.id}")

    click_button('top-test')

    expect_monthly_mass_mailing_form(expect_messages: [[:flash_notice, I18n.t('messages.monthly_mailing_test_sent')]],
                                     subject: 'The subject',
                                     pre_late_input: 'The pre_late_input',
                                     pre_coming_input: 'The pre_coming_input',
                                     awaiting_approval: 'The completed_awaiting_input',
                                     completed_events: 'The completed_input',
                                     closing_paragraph: 'The closing_input',
                                     salutation_input: 'The salutation_input',
                                     from_input: 'The from_input')

    # no candidate is selected

    click_button('top-test')

    expect_monthly_mass_mailing_form(expect_messages: [[:flash_alert, I18n.t('messages.no_candidate_selected')]],
                                     subject: 'The subject',
                                     pre_late_input: 'The pre_late_input',
                                     pre_coming_input: 'The pre_coming_input',
                                     awaiting_approval: 'The completed_awaiting_input',
                                     completed_events: 'The completed_input',
                                     closing_paragraph: 'The closing_input',
                                     salutation_input: 'The salutation_input',
                                     from_input: 'The from_input')
  end

  def expect_monthly_mass_mailing_form(values = {
    subject: I18n.t('email.subject_initial_input'),
    pre_late_input: I18n.t('email.late_initial_input'),
    pre_coming_input: I18n.t('email.coming_due_initial_input'),
    awaiting_approval: I18n.t('email.completed_awaiting_initial_input'),
    completed_events: I18n.t('email.completed_initial_input'),
    closing_paragraph: I18n.t('email.closing_initial_input'),
    salutation_input: I18n.t('email.salutation_initial_input'),
    from_input: /.*Vicki Kristoff.*|.*stmm.confirmation@kristoffs.com.*|.*919-249-5629.*/
  })

    # street_1 = values[:street_1].nil? ? STREET_1 : values[:street_1]

    expect_messages(values[:expect_messages]) unless values[:expect_messages].nil?
    expect(page).to have_field(I18n.t('email.subject_label'), with: values[:subject].presence ? values[:subject] : I18n.t('email.subject_initial_input'))
    expect(page).to have_field(I18n.t('email.pre_late_input_label'), with: values[:pre_late_input].presence ? values[:pre_late_input] : I18n.t('email.late_initial_input'))
    expect(page).to have_field(I18n.t('email.pre_coming_due_input_label'), with: values[:pre_coming_input].presence ? values[:pre_coming_input] : I18n.t('email.coming_due_initial_input'))
    expect(page).to have_field(I18n.t('email.completed_awaiting_input_label'), with: values[:awaiting_approval].presence ? values[:awaiting_approval] : I18n.t('email.completed_awaiting_initial_input'))
    expect(page).to have_field(I18n.t('email.completed_input_label'), with: values[:completed_events].presence ? values[:completed_events] : I18n.t('email.completed_initial_input'))
    expect(page).to have_field(I18n.t('email.closing_input_label'), with: values[:closing_paragraph].presence ? values[:closing_paragraph] : I18n.t('email.closing_initial_input'))
    expect(page).to have_field(I18n.t('email.salutation_input_label'), with: values[:salutation_input].presence ? values[:salutation_input] : I18n.t('email.salutation_initial_input'))
    expect(page).to have_css('textarea[id=mail_from_input]', text: values[:from_input].presence ? values[:from_input] : /.*Vicki Kristoff.*|.*stmm.confirmation@kristoffs.com.*|.*919-249-5629.*/)
  end
end
