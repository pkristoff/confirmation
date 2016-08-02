include Warden::Test::Helpers
Warden.test_mode!

feature 'Baptismal Certificate', :devise do

  before(:each) do
    @candidate = FactoryGirl.create(:candidate)
    AppFactory.add_confirmation_event(I18n.t('events.upload_baptismal_certificate'))
    login_as(@candidate, scope: :candidate)

    @path = dev_upload_baptismal_certificate_path(@candidate.id)
    @dev = 'dev/'
  end

  after(:each) do
    Warden.test_reset!
  end

  #dev

  it_behaves_like 'upload_baptismal_certificate_html_erb'

end
