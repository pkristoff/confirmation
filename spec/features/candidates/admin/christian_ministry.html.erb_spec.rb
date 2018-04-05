# frozen_string_literal: true

Warden.test_mode!

require 'constants'

feature 'Christian Ministry admin', :devise do
  include Warden::Test::Helpers

  before(:each) do
    @admin = FactoryBot.create(:admin)
    @candidate = FactoryBot.create(:candidate)
    login_as(@admin, scope: :admin)

    @path = christian_ministry_path(@candidate.id)
    @path_str = 'christian_ministry'
    @update_id = 'top-update'
    cand_name = 'Sophia Agusta'
    @updated_message = I18n.t('messages.updated', cand_name: cand_name)
    @updated_failed_verification = I18n.t('messages.updated', cand_name: cand_name)
    @is_dev = false
    @is_verify = false
  end

  after(:each) do
    Warden.test_reset!
  end

  it_behaves_like 'christian_ministry_html_erb'
end
