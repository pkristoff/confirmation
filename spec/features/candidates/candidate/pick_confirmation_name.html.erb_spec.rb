# frozen_string_literal: true

Warden.test_mode!

require 'constants'

feature 'Pick confirmation name', :devise do
  include Warden::Test::Helpers

  before(:each) do
    @admin = FactoryBot.create(:admin)
    @candidate = FactoryBot.create(:candidate)
    login_as(@candidate, scope: :candidate)

    @path = dev_pick_confirmation_name_path(@candidate.id)
    @path_str = 'pick_confirmation_name'
    @update_id = 'top-update'
    cand_name = 'Sophia Agusta'
    @updated_message = I18n.t('messages.updated', cand_name: cand_name)
    @updated_failed_verification = I18n.t('messages.updated', cand_name: cand_name)
    @is_dev = true
    @is_verify = false
  end

  after(:each) do
    Warden.test_reset!
  end

  # dev

  context 'test spanish' do
    let(:locale) { 'es' }

    it_behaves_like 'pick_confirmation_name_html_erb'
  end

  context 'test english' do
    let(:locale) { 'en' }

    it_behaves_like 'pick_confirmation_name_html_erb'
  end
end
