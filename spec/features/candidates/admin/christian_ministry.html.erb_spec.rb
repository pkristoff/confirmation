include Warden::Test::Helpers
Warden.test_mode!

require 'constants'

feature 'Christian Ministry admin', :devise do

  before(:each) do
    @is_dev = false
  end

  after(:each) do
    Warden.test_reset!
  end

  it_behaves_like 'christian_ministry_html_erb'

end
