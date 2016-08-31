include Warden::Test::Helpers
Warden.test_mode!

require 'constants'

feature 'Pick confirmation name admin', :devise do

  before(:each) do
    @is_dev = false
  end

  after(:each) do
    Warden.test_reset!
  end

  it_behaves_like 'pick_confirmation_name_html_erb'

end
