include ViewsHelpers
include Warden::Test::Helpers
Warden.test_mode!


feature 'Admin monthly mass mailing', :devise do

  after(:each) do
    Warden.test_reset!
  end

  scenario 'admin has to select candidate' do
    admin = FactoryGirl.create(:admin)
    login_as(admin, :scope => :admin)

    visit adhoc_mailing_path

    fill_in I18n.t('email.subject_label'), with: 'The subject'
    fill_in I18n.t('email.body_label'), with: 'The body'

    click_button('top-update')

    # puts page.html
    expect_message(:flash_alert, I18n.t('messages.no_candidate_selected'))
    expect(page).to have_field(I18n.t('email.subject_label'), with: 'The subject')
    expect(page).to have_field(I18n.t('email.body_label'), with: 'The body')

  end

  scenario 'admin can send email to multiple candidates' do

    candidate_1 = create_candidate('Vicki', 'Anne', 'Kristoff')
    candidate_2 = create_candidate('Paul', 'Richard', 'Kristoff')

    admin = FactoryGirl.create(:admin)
    AppFactory.add_confirmation_events

    login_as(admin, :scope => :admin)

    visit adhoc_mailing_path

    fill_in I18n.t('email.subject_label'), with: 'The subject'
    fill_in I18n.t('email.body_label'), with: 'The body'

    check("candidate_candidate_ids_#{candidate_1.id}")
    check("candidate_candidate_ids_#{candidate_2.id}")
    click_button('top-update')

    expect_message(:flash_notice, I18n.t('messages.adhoc_mailing_progress'))
    expect(page).to have_field(I18n.t('email.subject_label'), with: 'The subject')
    expect(page).to have_field(I18n.t('email.body_label'), with: 'The body')

  end

  scenario 'admin can send test adhoc email to self' do

    candidate_1 = create_candidate('Vicki', 'Anne', 'Kristoff')

    admin = FactoryGirl.create(:admin)
    AppFactory.add_confirmation_events

    login_as(admin, :scope => :admin)

    visit adhoc_mailing_path

    fill_in I18n.t('email.subject_label'), with: 'The subject'
    fill_in I18n.t('email.body_label'), with: 'The body'
    check("candidate_candidate_ids_#{candidate_1.id}")
    click_button('top-test')

    expect_message(:flash_notice, I18n.t('messages.adhoc_mailing_test_sent'))
    expect(page).to have_field(I18n.t('email.subject_label'), with: 'The subject')
    expect(page).to have_field(I18n.t('email.body_label'), with: 'The body')

  end

  scenario 'admin has to select candidate for adhoc test' do
    admin = FactoryGirl.create(:admin)
    login_as(admin, :scope => :admin)

    visit adhoc_mailing_path

    fill_in I18n.t('email.subject_label'), with: 'The subject'
    fill_in I18n.t('email.body_label'), with: 'The body'

    click_button('top-test')

    # puts page.html
    expect_message(:flash_alert, I18n.t('messages.no_candidate_selected'))
    expect(page).to have_field(I18n.t('email.subject_label'), with: 'The subject')
    expect(page).to have_field(I18n.t('email.body_label'), with: 'The body')

  end

end




