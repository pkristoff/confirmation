include Warden::Test::Helpers
Warden.test_mode!

require 'constants'

feature 'Baptismal Certificate candidate', :devise do

  before(:each) do
    @is_dev = true
    @is_verify = false
    @path_str = 'event_with_picture'
    @update_id = 'top-update'
    @button_name = I18n.t('views.common.update')
    cand_name = 'Sophia Agusta'
    @updated_message = I18n.t('messages.updated', cand_name: cand_name)
    @updated_failed_verification = I18n.t('messages.updated', cand_name: cand_name)
  end

  after(:each) do
    Warden.test_reset!
  end

  #dev

  it_behaves_like 'baptismal_certificate_html_erb'

end
