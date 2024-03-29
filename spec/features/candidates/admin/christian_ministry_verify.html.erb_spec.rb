# frozen_string_literal: true

Warden.test_mode!

require 'constants'

describe 'Christian Ministry verify admin', :devise do
  include Warden::Test::Helpers

  before do
    AppFactory.generate_default_status
    @admin = FactoryBot.create(:admin)
    @candidate = FactoryBot.create(:candidate)
    login_as(@admin, scope: :admin)

    @path = christian_ministry_verify_path(@candidate.id)
    @path_str = 'christian_ministry_verify'
    @update_id = 'top-update-verify'
    @is_dev = false
    @is_verify = true
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
