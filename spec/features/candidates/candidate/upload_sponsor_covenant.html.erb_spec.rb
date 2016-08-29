include Warden::Test::Helpers
Warden.test_mode!

require 'constants'

feature 'Sponsor Covenant candidate', :devise do

  before(:each) do
    @candidate = FactoryGirl.create(:candidate)
    AppFactory.add_confirmation_event(I18n.t('events.upload_sponsor_covenant'))
    login_as(@candidate, scope: :candidate)

    @path = dev_event_with_picture_path(@candidate.id, Event::Route::UPLOAD_SPONSOR_COVENANT)
    @dev = 'dev/'
  end

  after(:each) do
    Warden.test_reset!
  end

  #dev

  it_behaves_like 'upload_sponsor_covenant_html_erb'

end
