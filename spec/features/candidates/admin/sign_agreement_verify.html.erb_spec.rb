include Warden::Test::Helpers
Warden.test_mode!

require 'constants'

feature 'Sign Agreement Verify admin sign in', :devise do

  before(:each) do
    @admin = FactoryBot.create(:admin)
    @candidate = FactoryBot.create(:candidate)
    login_as(@admin, scope: :admin)
    @is_verify = true
    @path = sign_agreement_verify_path(@candidate.id)
    @dev = ''

    @path_str = 'sign_agreement_verify'
    @update_id = 'top-update-verify'
    cand_name = 'Sophia Agusta'
    @updated_message = I18n.t('messages.updated_verified', cand_name: cand_name)
    @updated_failed_verification = I18n.t('messages.updated_not_verified', cand_name: cand_name)

    @event_name = I18n.t('events.candidate_covenant_agreement')
    @sign_agreement_setter = :signed_agreement=
    @sign_agreement_getter = :signed_agreement
    @form_action = "form[id=edit_candidate][action=\"/#{@dev}#{@path_str}.#{@candidate.id}\"]"
    @field_name = I18n.t('label.sign_agreement.signed_agreement')
    @documant_key = Event::Document::CANDIDATE_COVENANT
  end

  after(:each) do
    Warden.test_reset!
  end

  it_behaves_like 'sign_an_agreement_html_erb'

end
