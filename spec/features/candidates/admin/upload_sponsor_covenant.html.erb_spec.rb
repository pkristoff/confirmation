include Warden::Test::Helpers
Warden.test_mode!

feature 'Sponsor Covenant admin', :devise do

  before(:each) do
    @admin = FactoryGirl.create(:admin)
    @candidate = FactoryGirl.create(:candidate)
    AppFactory.add_confirmation_event(I18n.t('events.upload_sponsor_covenant'))
    login_as(@admin, scope: :admin)

    @path = upload_sponsor_covenant_path(@candidate.id)
    @dev = ''
  end

  after(:each) do
    Warden.test_reset!
  end

  it_behaves_like 'upload_sponsor_covenant_html_erb'

end
