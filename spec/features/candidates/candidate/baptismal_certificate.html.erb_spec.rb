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
    @updated_message = I18n.t('messages.updated')
    @updated_failed_verification = I18n.t('messages.updated')
  end

  after(:each) do
    Warden.test_reset!
  end

  #dev

  it_behaves_like 'baptismal_certificate_html_erb'

end
