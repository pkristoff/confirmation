include Warden::Test::Helpers
Warden.test_mode!

feature 'Sponsor Covenant candidate', :devise do

  before(:each) do
    @candidate = FactoryGirl.create(:candidate)
    AppFactory.add_confirmation_event(I18n.t('events.pick_confirmation_name'))
    login_as(@candidate, scope: :candidate)

    @path = dev_pick_confirmation_name_path(@candidate.id)
    @dev = 'dev/'
  end

  after(:each) do
    Warden.test_reset!
  end

  #dev

  it_behaves_like 'pick_confirmation_name_html_erb'

end
