include Warden::Test::Helpers
Warden.test_mode!

require 'constants'

feature 'Retreat Verification admin', :devise do

  before(:each) do
    @is_dev = false
  end

  after(:each) do
    Warden.test_reset!
  end

  it_behaves_like 'retreat_verification_html_erb'

end
