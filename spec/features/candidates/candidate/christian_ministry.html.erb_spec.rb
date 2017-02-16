include Warden::Test::Helpers
Warden.test_mode!

require 'constants'

feature 'Christian Ministry  candidate', :devise do

  before(:each) do
    @admin = FactoryGirl.create(:admin)
    @candidate = FactoryGirl.create(:candidate)
    login_as(@admin, scope: :admin)

    @path = christian_ministry_path(@candidate.id)
    @is_dev = true
  end

  after(:each) do
    Warden.test_reset!
  end

  #dev

  it_behaves_like 'christian_ministry_html_erb'

end
