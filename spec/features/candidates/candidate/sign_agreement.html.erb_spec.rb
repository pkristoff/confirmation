include Warden::Test::Helpers
Warden.test_mode!

feature 'Sign Agreement', :devise do

  before(:each) do
    @candidate = FactoryGirl.create(:candidate)
    login_as(@candidate, scope: :candidate)

    @path = dev_sign_agreement_path(@candidate.id)
    @dev = 'dev/'
  end

  after(:each) do
    Warden.test_reset!
  end

  it_behaves_like 'Sign Agreement'

end
