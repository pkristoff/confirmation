include Warden::Test::Helpers
Warden.test_mode!

# Feature: Admin index page
#   As a admin
#   I want to see a list of admins
#   So I can see who has registered
feature 'Admin events page', :devise do

  after(:each) do
    Warden.test_reset!
  end

  scenario 'admin list of no events' do
    admin = FactoryGirl.create(:admin)
    login_as(admin, scope: :admin)
    visit events_path

    expect(page).to have_selector('form', count: 0)
  end

  scenario 'admin list of 1 events' do
    AppFactory.add_confirmation_event(I18n.t('events.sign_agreement'))
    admin = FactoryGirl.create(:admin)
    login_as(admin, scope: :admin)
    visit events_path

    expect(page).to have_selector('form', count: 1)
  end

  scenario 'admin list of 2 events' do
    AppFactory.add_confirmation_event(I18n.t('events.sign_agreement'))
    AppFactory.add_confirmation_event(I18n.t('events.candidate_information_sheet'))
    admin = FactoryGirl.create(:admin)
    login_as(admin, scope: :admin)
    visit events_path

    expect(page).to have_selector('form', count: 2)
  end

end
