include ViewsHelpers
include Warden::Test::Helpers
Warden.test_mode!


feature 'Admin monthly mass mailing', :devise do

  after(:each) do
    Warden.test_reset!
  end

  scenario 'admin has to select candidate before sending monthly email' do
    admin = FactoryGirl.create(:admin)
    login_as(admin, :scope => :admin)
    visit monthly_mass_mailing_path

    fill_in I18n.t('email.subject_label'), with: 'The subject'
    fill_in I18n.t('email.pre_late_text_label'), with: 'The pre_late_text'
    fill_in I18n.t('email.pre_coming_due_text_label'), with: 'The pre_coming_text'
    fill_in I18n.t('email.completed_text_label'), with: 'The completed_text'
    fill_in I18n.t('email.closing_text_label'), with: 'The closing_text'
    fill_in I18n.t('email.salutation_text_label'), with: 'The salutation_text'
    fill_in I18n.t('email.from_text_label'), with: 'The from_text'
    click_button('top-update')

    expect_message(:flash_alert, I18n.t('messages.no_candidate_selected'))
    expect(page).to have_field(I18n.t('email.subject_label'), with: 'The subject')
    expect(page).to have_field(I18n.t('email.pre_late_text_label'), with: 'The pre_late_text')
    expect(page).to have_field(I18n.t('email.pre_coming_due_text_label'), with: 'The pre_coming_text')
    expect(page).to have_field(I18n.t('email.completed_text_label'), with: 'The completed_text')
    expect(page).to have_field(I18n.t('email.closing_text_label'), with: 'The closing_text')
    expect(page).to have_field(I18n.t('email.salutation_text_label'), with: 'The salutation_text')
    expect(page).to have_field(I18n.t('email.from_text_label'), with: 'The from_text')

  end

  scenario 'admin can send email to multiple candidates' do

    candidate_1 = create_candidate('Vicki', 'Anne', 'Kristoff')
    candidate_2 = create_candidate('Paul', 'Richard', 'Kristoff')

    admin = FactoryGirl.create(:admin)
    AppFactory.add_confirmation_events

    login_as(admin, :scope => :admin)

    visit monthly_mass_mailing_path

    fill_in I18n.t('email.subject_label'), with: 'The subject'
    fill_in I18n.t('email.pre_late_text_label'), with: 'The pre_late_text'
    fill_in I18n.t('email.pre_coming_due_text_label'), with: 'The pre_coming_text'
    fill_in I18n.t('email.completed_text_label'), with: 'The completed_text'
    fill_in I18n.t('email.closing_text_label'), with: 'The closing_text'
    fill_in I18n.t('email.salutation_text_label'), with: 'The salutation_text'
    fill_in I18n.t('email.from_text_label'), with: 'The from_text'

    check("candidate_candidate_ids_#{candidate_1.id}")
    check("candidate_candidate_ids_#{candidate_2.id}")

    click_button('top-update')

    expect_message(:flash_notice, I18n.t('messages.monthly_mailing_progress'))
    expect(page).to have_field(I18n.t('email.subject_label'), with: 'The subject')
    expect(page).to have_field(I18n.t('email.pre_late_text_label'), with: 'The pre_late_text')
    expect(page).to have_field(I18n.t('email.pre_coming_due_text_label'), with: 'The pre_coming_text')
    expect(page).to have_field(I18n.t('email.completed_text_label'), with: 'The completed_text')
    expect(page).to have_field(I18n.t('email.closing_text_label'), with: 'The closing_text')
    expect(page).to have_field(I18n.t('email.salutation_text_label'), with: 'The salutation_text')
    expect(page).to have_field(I18n.t('email.from_text_label'), with: 'The from_text')

  end
  scenario 'admin can send email to multiple candidates with default values' do

    candidate_1 = create_candidate('Vicki', 'Anne', 'Kristoff')
    candidate_2 = create_candidate('Paul', 'Richard', 'Kristoff')

    admin = FactoryGirl.create(:admin)
    AppFactory.add_confirmation_events

    login_as(admin, :scope => :admin)

    visit monthly_mass_mailing_path

    check("candidate_candidate_ids_#{candidate_1.id}")
    check("candidate_candidate_ids_#{candidate_2.id}")

    click_button('top-update')

    expect_message(:flash_notice, I18n.t('messages.monthly_mailing_progress'))
    expect_default_values

  end

  scenario 'admin has to select candidate before sending test monthly email' do
    admin = FactoryGirl.create(:admin)
    login_as(admin, :scope => :admin)
    visit monthly_mass_mailing_path

    fill_in I18n.t('email.subject_label'), with: 'The subject'
    fill_in I18n.t('email.pre_late_text_label'), with: 'The pre_late_text'
    fill_in I18n.t('email.pre_coming_due_text_label'), with: 'The pre_coming_text'
    fill_in I18n.t('email.completed_text_label'), with: 'The completed_text'
    fill_in I18n.t('email.closing_text_label'), with: 'The closing_text'
    fill_in I18n.t('email.salutation_text_label'), with: 'The salutation_text'
    fill_in I18n.t('email.from_text_label'), with: 'The from_text'
    click_button('top-test')

    expect_message(:flash_alert, I18n.t('messages.no_candidate_selected'))
    expect(page).to have_field(I18n.t('email.subject_label'), with: 'The subject')
    expect(page).to have_field(I18n.t('email.pre_late_text_label'), with: 'The pre_late_text')
    expect(page).to have_field(I18n.t('email.pre_coming_due_text_label'), with: 'The pre_coming_text')
    expect(page).to have_field(I18n.t('email.completed_text_label'), with: 'The completed_text')
    expect(page).to have_field(I18n.t('email.closing_text_label'), with: 'The closing_text')
    expect(page).to have_field(I18n.t('email.salutation_text_label'), with: 'The salutation_text')
    expect(page).to have_field(I18n.t('email.from_text_label'), with: 'The from_text')

  end

  scenario 'admin can send test email to a candidate with default values' do

    candidate_1 = create_candidate('Vicki', 'Anne', 'Kristoff')

    admin = FactoryGirl.create(:admin)
    AppFactory.add_confirmation_events

    login_as(admin, :scope => :admin)

    visit monthly_mass_mailing_path

    check("candidate_candidate_ids_#{candidate_1.id}")
    click_button('top-test')

    expect_message(:flash_notice, I18n.t('messages.monthly_mailing_test_sent'))
    expect_default_values

  end

  scenario 'admin can send test email to a candidate' do

    candidate_1 = create_candidate('Vicki', 'Anne', 'Kristoff')

    admin = FactoryGirl.create(:admin)
    AppFactory.add_confirmation_events

    login_as(admin, :scope => :admin)

    visit monthly_mass_mailing_path

    fill_in I18n.t('email.subject_label'), with: 'The subject'
    fill_in I18n.t('email.pre_late_text_label'), with: 'The pre_late_text'
    fill_in I18n.t('email.pre_coming_due_text_label'), with: 'The pre_coming_text'
    fill_in I18n.t('email.completed_text_label'), with: 'The completed_text'
    fill_in I18n.t('email.closing_text_label'), with: 'The closing_text'
    fill_in I18n.t('email.salutation_text_label'), with: 'The salutation_text'
    fill_in I18n.t('email.from_text_label'), with: 'The from_text'
    check("candidate_candidate_ids_#{candidate_1.id}")
    click_button('top-test')

    expect_message(:flash_notice, I18n.t('messages.monthly_mailing_test_sent'))
    expect(page).to have_field(I18n.t('email.subject_label'), with: 'The subject')
    expect(page).to have_field(I18n.t('email.pre_late_text_label'), with: 'The pre_late_text')
    expect(page).to have_field(I18n.t('email.pre_coming_due_text_label'), with: 'The pre_coming_text')
    expect(page).to have_field(I18n.t('email.completed_text_label'), with: 'The completed_text')
    expect(page).to have_field(I18n.t('email.closing_text_label'), with: 'The closing_text')
    expect(page).to have_field(I18n.t('email.salutation_text_label'), with: 'The salutation_text')
    expect(page).to have_field(I18n.t('email.from_text_label'), with: 'The from_text')

  end

  def expect_default_values

    expect(page).to have_field(I18n.t('email.subject_label'), with: I18n.t('email.subject_initial_text'))
    expect(page).to have_field(I18n.t('email.pre_late_text_label'), with: I18n.t('email.late_initial_text'))
    expect(page).to have_field(I18n.t('email.pre_coming_due_text_label'), with: I18n.t('email.coming_due_initial_text'))
    expect(page).to have_field(I18n.t('email.completed_text_label'), with: I18n.t('email.completed_initial_text'))
    expect(page).to have_field(I18n.t('email.closing_text_label'), with: I18n.t('email.closing_initial_text'))
    expect(page).to have_field(I18n.t('email.salutation_text_label'), with: I18n.t('email.salutation_initial_text'))
    expect(page).to have_css('textarea[id=mail_from_text]', text: /.*Vicki Kristoff.*|.*stmm.confirmation@kristoffs.com.*|.*919-249-5629.*/)

  end

end




