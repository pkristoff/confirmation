include Warden::Test::Helpers
Warden.test_mode!

feature 'Pick confirmation name admin', :devise do

  before(:each) do
    @admin = FactoryGirl.create(:admin)
    @candidate = FactoryGirl.create(:candidate)
    AppFactory.add_confirmation_event(I18n.t('events.pick_confirmation_name'))
    login_as(@admin, scope: :admin)

    @path = pick_confirmation_name_path(@candidate.id)
    @dev = ''
  end

  after(:each) do
    Warden.test_reset!
  end

  it_behaves_like 'pick_confirmation_name_html_erb'

end
