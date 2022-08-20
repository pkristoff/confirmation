# frozen_string_literal: true

Warden.test_mode!

require 'constants'

describe 'Sponsor Eligibility admin', :devise do
  include Warden::Test::Helpers

  before do
    @is_dev = false
    @is_verify = false
    @path_str = 'event_with_picture'
    @update_id = 'top-update'
    @button_name = I18n.t('views.common.update')
    cand_name = 'Sophia Augusta'
    @updated_message = I18n.t('messages.updated', cand_name: cand_name)
    @updated_failed_verification = I18n.t('messages.updated', cand_name: cand_name)
  end

  after do
    Warden.test_reset!
  end

  context 'with english' do
    let(:locale) { 'en' }

    it_behaves_like 'sponsor_eligibility_html_erb'
  end

  context 'with spanish' do
    let(:locale) { 'es' }

    it_behaves_like 'sponsor_eligibility_html_erb'
  end
end
