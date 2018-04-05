# frozen_string_literal: true

Warden.test_mode!

feature 'Candidate sheet admin', :devise do
  include Warden::Test::Helpers

  before(:each) do
    @admin = FactoryBot.create(:admin)
    @candidate = FactoryBot.create(:candidate)
    login_as(@admin, scope: :admin)

    @path = candidate_sheet_path(@candidate.id)
    @dev = ''

    @admin_verified = false
    @path_str = 'candidate_sheet'
    @update_id = 'top-update'
    cand_name = 'Sophia Agusta'
    @updated_message = I18n.t('messages.updated', cand_name: cand_name)
    @updated_failed_verification = I18n.t('messages.updated', cand_name: cand_name)
    @is_verify = false
  end

  after(:each) do
    Warden.test_reset!
  end

  it_behaves_like 'candidate_sheet_html_erb'
end
