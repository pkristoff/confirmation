# frozen_string_literal: true

Warden.test_mode!

require 'constants'

describe 'Christian Ministry admin', :devise do
  include Warden::Test::Helpers

  before do
    AppFactory.generate_default_status
    @admin = FactoryBot.create(:admin)
    @candidate = FactoryBot.create(:candidate)
    login_as(@admin, scope: :admin)

    @path = christian_ministry_path(@candidate.id)
    @path_str = 'christian_ministry'
    @update_id = 'top-update'
    @is_dev = false
    @is_verify = false
  end

  after do
    Warden.test_reset!
  end

  context 'with english' do
    let(:locale) { 'en' }

    it_behaves_like 'christian_ministry_html_erb'
  end

  context 'with spanish' do
    let(:locale) { 'es' }

    it_behaves_like 'christian_ministry_html_erb'
  end
end
