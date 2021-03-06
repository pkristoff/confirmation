# frozen_string_literal: true

Warden.test_mode!

require 'constants'

feature 'Christian Ministry  candidate', :devise do
  include Warden::Test::Helpers

  before(:each) do
    @admin = FactoryBot.create(:admin)
    @candidate = FactoryBot.create(:candidate)
    login_as(@candidate, scope: :candidate)

    @path = dev_christian_ministry_path(@candidate.id)
    @path_str = 'christian_ministry'
    @update_id = 'top-update'
    @is_dev = true
    @is_verify = false
  end

  after(:each) do
    Warden.test_reset!
  end

  # dev

  context 'test spanish' do
    let(:locale) { 'es' }

    it_behaves_like 'christian_ministry_html_erb'
  end

  context 'test english' do
    let(:locale) { 'en' }

    it_behaves_like 'christian_ministry_html_erb'
  end
end
