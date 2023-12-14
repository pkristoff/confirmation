# frozen_string_literal: true

Warden.test_mode!

require 'constants'

describe 'ChristianMinistry candidate', :devise do
  include Warden::Test::Helpers

  before do
    AppFactory.generate_default_status
    @admin = FactoryBot.create(:admin)
    @candidate = FactoryBot.create(:candidate)
    login_as(@candidate, scope: :candidate)

    @path = dev_christian_ministry_path(@candidate.id)
    @path_str = 'christian_ministry'
    @update_id = 'top-update'
    @is_dev = true
    @is_verify = false
  end

  after do
    Warden.test_reset!
  end

  # dev

  context 'with english' do
    let(:locale) { 'en' }

    it_behaves_like 'christian_ministry_html_erb'
  end

  context 'with spanish' do
    let(:locale) { 'es' }

    it_behaves_like 'christian_ministry_html_erb'
  end
end
