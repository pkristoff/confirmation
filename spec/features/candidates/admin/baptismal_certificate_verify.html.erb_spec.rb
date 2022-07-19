# frozen_string_literal: true

Warden.test_mode!

require 'constants'

feature 'Baptismal Certificate admin Verify', :devise do
  include Warden::Test::Helpers

  before(:each) do
    @is_dev = false
    @is_verify = true
    @path_str = 'event_with_picture_verify'
    @update_id = 'top-update-verify'
  end

  after(:each) do
    Warden.test_reset!
  end

  context 'test english' do
    let(:locale) { 'en' }
    it_behaves_like 'baptismal_certificate_html_erb'
  end

  context 'test spanish' do
    let(:locale) { 'es' }

    it_behaves_like 'baptismal_certificate_html_erb'
  end
  # dev
end
