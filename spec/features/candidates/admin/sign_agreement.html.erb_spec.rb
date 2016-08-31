include Warden::Test::Helpers
Warden.test_mode!

require 'constants'

feature 'Sign Agreement admin sign in', :devise do

  before(:each) do
    @admin = FactoryGirl.create(:admin)
    @candidate = FactoryGirl.create(:candidate)
    login_as(@admin, scope: :admin)

    @path = sign_agreement_path(@candidate.id)
    @dev = ''
    @event_name = I18n.t('events.sign_agreement')
    @sign_agreement_setter = :signed_agreement=
    @sign_agreement_getter = :signed_agreement
    @form_action = "form[id=edit_candidate][action=\"/#{@dev}sign_agreement.#{@candidate.id}\"]"
    @field_name = 'Signed agreement'
    @documant_key = Event::Document::CANDIDATE_COVENANT
    @event_offset = 2
  end

  after(:each) do
    Warden.test_reset!
  end

  it_behaves_like 'sign_an_agreement_html_erb'

end
