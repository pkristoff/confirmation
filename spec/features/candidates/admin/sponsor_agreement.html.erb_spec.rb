include Warden::Test::Helpers
Warden.test_mode!

require 'constants'

feature 'Sponsor Agreement admin', :devise do

  before(:each) do
    @admin = FactoryGirl.create(:admin)
    @candidate = FactoryGirl.create(:candidate)
    @confirmation_event = AppFactory.add_confirmation_event(I18n.t('events.sponsor_covenant'))
    login_as(@admin, scope: :admin)

    @path = sponsor_agreement_path(@candidate.id)
    @dev = ''
    @event_name = I18n.t('events.sponsor_agreement')
    @sign_agreement_setter = :sponsor_agreement=
    @sign_agreement_getter = :sponsor_agreement
    @form_action = "form[id=edit_candidate][action=\"/#{@dev}sponsor_agreement.#{@candidate.id}\"]"
    @field_name = I18n.t('label.sponsor_agreement.sponsor_agreement')
    @documant_key = Event::Document::CONVERSATION_SPONSOR_CANDIDATE
  end

  after(:each) do
    Warden.test_reset!
  end

  it_behaves_like 'sign_an_agreement_html_erb'

end
