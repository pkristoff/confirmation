include Warden::Test::Helpers
Warden.test_mode!

require 'constants'

feature 'Sponsor Agreement verify admin', :devise do

  before(:each) do
    @admin = FactoryBot.create(:admin)
    @candidate = FactoryBot.create(:candidate)
    @confirmation_event = AppFactory.add_confirmation_event(I18n.t('events.sponsor_agreement'))
    login_as(@admin, scope: :admin)

    @path = sponsor_agreement_verify_path(@candidate.id)
    @dev = ''
    @event_name = I18n.t('events.sponsor_agreement')
    @is_verify = true

    @path_str = 'sponsor_agreement_verify'
    @update_id = 'top-update-verify'
    cand_name = 'Sophia Agusta'
    @updated_message = I18n.t('messages.updated_verified', cand_name: cand_name)
    @updated_failed_verification = I18n.t('messages.updated_not_verified', cand_name: cand_name)

    @sign_agreement_setter = :sponsor_agreement=
    @sign_agreement_getter = :sponsor_agreement
    @form_action = "form[id=edit_candidate][action=\"/#{@dev}#{@path_str}.#{@candidate.id}\"]"
    @field_name = I18n.t('label.sponsor_agreement.sponsor_agreement')
    @documant_key = Event::Document::CONVERSATION_SPONSOR_CANDIDATE
  end

  after(:each) do
    Warden.test_reset!
  end

  it_behaves_like 'sign_an_agreement_html_erb'

end
