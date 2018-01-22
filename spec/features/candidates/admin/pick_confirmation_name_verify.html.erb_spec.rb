include Warden::Test::Helpers
Warden.test_mode!

require 'constants'

feature 'Pick confirmation name verify admin', :devise do

  before(:each) do
    @admin = FactoryBot.create(:admin)
    @candidate = FactoryBot.create(:candidate)
    login_as(@admin, scope: :admin)

    @path = pick_confirmation_name_verify_path(@candidate.id)
    @path_str = 'pick_confirmation_name_verify'
    @update_id = 'top-update-verify'
    cand_name = 'Sophia Agusta'
    @updated_message = I18n.t('messages.updated_verified', cand_name: cand_name)
    @updated_failed_verification = I18n.t('messages.updated_not_verified', cand_name: cand_name)
    @is_dev = false
  end

  after(:each) do
    Warden.test_reset!
  end

  it_behaves_like 'pick_confirmation_name_html_erb'

end
