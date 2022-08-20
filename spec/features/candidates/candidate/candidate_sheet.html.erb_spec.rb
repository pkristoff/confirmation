# frozen_string_literal: true

Warden.test_mode!

describe 'Candidate sheet candidate', :devise do
  include Warden::Test::Helpers

  before do
    @candidate = FactoryBot.create(:candidate)
    login_as(@candidate, scope: :candidate)

    @path = dev_candidate_sheet_path(@candidate.id)
    @dev = 'dev/'

    @admin_verified = false
    @path_str = 'candidate_sheet'
    @update_id = 'top-update'
    @is_verify = false
  end

  after do
    Warden.test_reset!
  end

  context 'with english' do
    let(:locale) { 'en' }

    it_behaves_like 'candidate_sheet_html_erb'
  end

  context 'with spanish' do
    let(:locale) { 'es' }

    it_behaves_like 'candidate_sheet_html_erb'
  end
end
