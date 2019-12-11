# frozen_string_literal: true

Warden.test_mode!

require 'constants'

feature 'Sign Agreement admin sign in', :devise do
  include Warden::Test::Helpers

  before(:each) do
    @admin = FactoryBot.create(:admin)
    @candidate = FactoryBot.create(:candidate)
    login_as(@admin, scope: :admin)
    @path = sign_agreement_path(@candidate.id)
    @dev = ''
    @is_verify = false

    @path_str = 'sign_agreement'
    @update_id = 'top-update'
    cand_name = 'Sophia Agusta'
    @updated_message = I18n.t('messages.updated', cand_name: cand_name)
    @updated_failed_verification = I18n.t('messages.updated', cand_name: cand_name)

    @event_name = Candidate.covenant_agreement_event_name
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
