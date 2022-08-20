# frozen_string_literal: true

Warden.test_mode!

require 'constants'

describe 'Retreat Verification admin verify', :devise do
  include Warden::Test::Helpers

  before do
    @is_dev = false
    @is_verify = true
    @path_str = 'event_with_picture_verify'
    @update_id = 'top-update-verify'
    @button_name = I18n.t('views.common.update_verify')
    cand_name = 'Sophia Augusta'
    @updated_message = I18n.t('messages.updated_verified', cand_name: cand_name)
    @updated_failed_verification = I18n.t('messages.updated_not_verified', cand_name: cand_name)
  end

  after do
    Warden.test_reset!
  end

  context 'with english' do
    let(:locale) { 'en' }

    it_behaves_like 'retreat_verification_html_erb'
  end

  context 'with spanish' do
    let(:locale) { 'es' }

    it_behaves_like 'retreat_verification_html_erb'
  end
end
