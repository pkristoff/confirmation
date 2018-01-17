include Warden::Test::Helpers
Warden.test_mode!

require 'constants'

feature 'Christian Ministry  candidate', :devise do

  before(:each) do
    @admin = FactoryBot.create(:admin)
    @candidate = FactoryBot.create(:candidate)
    login_as(@admin, scope: :admin)

    @path = christian_ministry_path(@candidate.id)
    @path_str = 'christian_ministry'
    @update_id = 'top-update'
    @updated_message = I18n.t('messages.updated')
    @updated_failed_verification = I18n.t('messages.updated')
    @is_dev = true
  end

  after(:each) do
    Warden.test_reset!
  end

  #dev

  it_behaves_like 'christian_ministry_html_erb'

end
