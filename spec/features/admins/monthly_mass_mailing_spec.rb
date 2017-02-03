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

    visit monthly_mass_mailing_path

    click_button('top-update')

    expect_message(:flash_alert, I18n.t('messages.no_candidate_selected'))

  end

  scenario 'admin can send email to multiple candidates' do

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

  end

end




