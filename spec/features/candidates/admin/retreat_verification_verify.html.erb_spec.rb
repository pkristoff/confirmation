# frozen_string_literal: true

Warden.test_mode!

require 'constants'

feature 'Retreat Verification admin verify', :devise do
  include Warden::Test::Helpers

  before(:each) do
    @is_dev = false
    @is_verify = true
    @path_str = 'event_with_picture_verify'
    @update_id = 'top-update-verify'
    @button_name = I18n.t('views.common.update_verify')
    cand_name = 'Sophia Agusta'
    @updated_message = I18n.t('messages.updated_verified', cand_name: cand_name)
    @updated_failed_verification = I18n.t('messages.updated_not_verified', cand_name: cand_name)
    Visitor.visitor('St. Michael\'s', 'ccc', 'hhh')
  end

  after(:each) do
    Warden.test_reset!
  end

  context 'test spanish' do
    let(:locale) { 'es' }

    it_behaves_like 'retreat_verification_html_erb'
  end

  context 'test english' do
    let(:locale) { 'en' }

    it_behaves_like 'retreat_verification_html_erb'
  end
end
