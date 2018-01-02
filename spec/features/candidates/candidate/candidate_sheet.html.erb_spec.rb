include Warden::Test::Helpers
Warden.test_mode!

feature 'Candidate sheet candidate', :devise do

  before(:each) do
    @candidate = FactoryBot.create(:candidate)
    login_as(@candidate, scope: :candidate)

    @path = dev_candidate_sheet_path(@candidate.id)
    @dev = 'dev/'
  end

  after(:each) do
    Warden.test_reset!
  end

  it_behaves_like 'candidate_sheet_html_erb'

end
