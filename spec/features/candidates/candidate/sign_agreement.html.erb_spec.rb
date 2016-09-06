include Warden::Test::Helpers
Warden.test_mode!

require('constants')

feature 'Sign Agreement candidate login in', :devise do

  before(:each) do
    @candidate = FactoryGirl.create(:candidate)
    login_as(@candidate, scope: :candidate)

    @path = dev_sign_agreement_path(@candidate.id)
    @dev = 'dev/'
    @event_name = I18n.t('events.candidate_covenant_agreement')
    @sign_agreement_setter = :signed_agreement=
    @sign_agreement_getter = :signed_agreement
    @form_action = "form[id=edit_candidate][action=\"/#{@dev}sign_agreement.#{@candidate.id}\"]"
    @field_name = I18n.t('label.sign_agreement.signed_agreement')
    @documant_key = Event::Document::CANDIDATE_COVENANT
    @event_offset = 2
  end

  after(:each) do
    Warden.test_reset!
  end

  it_behaves_like 'sign_an_agreement_html_erb'

end
