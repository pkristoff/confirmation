# frozen_string_literal: true

Warden.test_mode!

require 'constants'

feature 'Pick confirmation name verify admin', :devise do
  include Warden::Test::Helpers

  before(:each) do
    @admin = FactoryBot.create(:admin)
    @candidate = FactoryBot.create(:candidate)
    login_as(@admin, scope: :admin)

    @path = pick_confirmation_name_verify_path(@candidate.id)
    @path_str = 'pick_confirmation_name_verify'
    @update_id = 'top-update-verify'
    @is_dev = false
    @is_verify = true
  end

  after(:each) do
    Warden.test_reset!
  end

  context 'test spanish' do
    let(:locale) { 'es' }

    it_behaves_like 'pick_confirmation_name_html_erb'
  end

  context 'test english' do
    let(:locale) { 'en' }

    it_behaves_like 'pick_confirmation_name_html_erb'
  end
end
