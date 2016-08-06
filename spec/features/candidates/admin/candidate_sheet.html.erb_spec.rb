include Warden::Test::Helpers
Warden.test_mode!

feature 'Candidate sheet admin', :devise do

  before(:each) do
    @admin = FactoryGirl.create(:admin)
    @candidate = FactoryGirl.create(:candidate)
    login_as(@admin, scope: :admin)

    @path = candidate_sheet_path(@candidate.id)
    @dev = ''
  end

  after(:each) do
    Warden.test_reset!
  end

  it_behaves_like 'candidate_sheet_html_erb'

end
