# frozen_string_literal: true

Warden.test_mode!

require 'constants'

describe 'Retreat Verification candidate', :devise do
  include Warden::Test::Helpers

  before do
    AppFactory.generate_default_status
    @is_dev = true
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

  # dev

  context 'with english' do
    let(:locale) { 'en' }

    it_behaves_like 'retreat_verification_html_erb'
  end

  context 'with spanish' do
    let(:locale) { 'es' }

    it_behaves_like 'retreat_verification_html_erb'
  end
end
