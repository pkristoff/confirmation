include Warden::Test::Helpers
Warden.test_mode!

feature 'Candidate sheet admin', :devise do

  before(:each) do
    @admin = FactoryBot.create(:admin)
    @candidate = FactoryBot.create(:candidate)
    login_as(@admin, scope: :admin)

    @path = candidate_sheet_verify_path(@candidate.id)
    @dev = ''
    @admin_verified = true
    @path_str = 'candidate_sheet_verify'
    @update_id = 'top-update-verify'
    cand_name = 'Sophia Agusta'
    @updated_message = I18n.t('messages.updated_verified', cand_name: cand_name)
    @updated_failed_verification = I18n.t('messages.updated_not_verified', cand_name: cand_name)
    @is_verify = true
  end

  after(:each) do
    Warden.test_reset!
  end

  it_behaves_like 'candidate_sheet_html_erb'

end
