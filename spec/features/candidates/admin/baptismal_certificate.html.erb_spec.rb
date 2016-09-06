include Warden::Test::Helpers
Warden.test_mode!

require 'constants'

feature 'Baptismal Certificate', :devise do

  before(:each) do
    @is_dev = false
  end

  after(:each) do
    Warden.test_reset!
  end

  it_behaves_like 'baptismal_certificate_html_erb'

end
