# frozen_string_literal: true

Warden.test_mode!

describe 'Candidate sheet admin', :devise do
  include Warden::Test::Helpers

  before do
    @admin = FactoryBot.create(:admin)
    @candidate = FactoryBot.create(:candidate)
    login_as(@admin, scope: :admin)

    @path = candidate_sheet_path(@candidate.id)
    @dev = ''

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
