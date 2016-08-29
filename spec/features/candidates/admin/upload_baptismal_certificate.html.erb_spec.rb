include Warden::Test::Helpers
Warden.test_mode!

require 'constants'

feature 'Baptismal Certificate', :devise do

  before(:each) do
    @admin = FactoryGirl.create(:admin)
    @candidate = FactoryGirl.create(:candidate)
    AppFactory.add_confirmation_event(I18n.t('events.upload_baptismal_certificate'))
    login_as(@admin, scope: :admin)

    @path = event_with_picture_path(@candidate.id, Event::Route::UPLOAD_BAPTISMAL_CERTIFICATE)
    @dev = ''
  end

  after(:each) do
    Warden.test_reset!
  end

  it_behaves_like 'upload_baptismal_certificate_html_erb'

end
