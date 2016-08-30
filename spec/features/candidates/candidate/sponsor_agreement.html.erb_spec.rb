include Warden::Test::Helpers
Warden.test_mode!

require 'constants'

feature 'Sponsor Agreement candidate', :devise do

  before(:each) do
    @candidate = FactoryGirl.create(:candidate)
    AppFactory.add_confirmation_event(I18n.t('events.upload_sponsor_covenant'))
    login_as(@candidate, scope: :candidate)

    @path = dev_sponsor_agreement_path(@candidate.id)
    @dev = 'dev/'
    @event_name = I18n.t('events.sponsor_agreement')
    @sign_agreement_setter = :sponsor_agreement=
    @sign_agreement_getter = :sponsor_agreement
    @form_action = "form[id=edit_candidate][action=\"/#{@dev}sponsor_agreement.#{@candidate.id}\"]"
    @field_name = 'Sponsor agreement'
    @event_offset = 3
  end

  after(:each) do
    Warden.test_reset!
  end

  #dev

  it_behaves_like 'sign_an_agreement_html_erb'

end

