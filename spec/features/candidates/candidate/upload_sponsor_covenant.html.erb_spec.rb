include Warden::Test::Helpers
Warden.test_mode!

require 'constants'

feature 'Sponsor Covenant candidate', :devise do

  before(:each) do
    @is_dev = true
  end

  after(:each) do
    Warden.test_reset!
  end

  #dev

  it_behaves_like 'upload_sponsor_covenant_html_erb'

end
