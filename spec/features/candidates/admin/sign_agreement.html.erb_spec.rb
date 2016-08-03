include Warden::Test::Helpers
Warden.test_mode!

feature 'Sign Agreement', :devise do

  before(:each) do
    @admin = FactoryGirl.create(:admin)
    @candidate = FactoryGirl.create(:candidate)
    login_as(@admin, scope: :admin)

    @path = sign_agreement_path(@candidate.id)
    @dev = ''
  end

  after(:each) do
    Warden.test_reset!
  end

  it_behaves_like 'Sign Agreement'

end
