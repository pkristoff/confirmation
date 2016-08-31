include Warden::Test::Helpers
Warden.test_mode!

require 'constants'

feature 'Christian Ministry  candidate', :devise do

  before(:each) do
    @is_dev = true
  end

  after(:each) do
    Warden.test_reset!
  end

  #dev

  it_behaves_like 'christian_ministry_html_erb'

end
