include Warden::Test::Helpers
Warden.test_mode!

feature 'Candidate sheet candidate', :devise do

  before(:each) do
    @candidate = FactoryBot.create(:candidate)
    login_as(@candidate, scope: :candidate)

    @path = dev_candidate_sheet_path(@candidate.id)
    @dev = 'dev/'

    @admin_verified = false
    @path_str = 'candidate_sheet'
    @update_id = 'top-update'
    cand_name = 'Sophia Agusta'
    @updated_message = I18n.t('messages.updated', cand_name: cand_name)
    @updated_failed_verification = I18n.t('messages.updated', cand_name: cand_name)
  end

  after(:each) do
    Warden.test_reset!
  end

  it_behaves_like 'candidate_sheet_html_erb'

end
