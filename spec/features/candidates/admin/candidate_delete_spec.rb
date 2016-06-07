include Warden::Test::Helpers
Warden.test_mode!

# Feature: Candidate delete
#   As a candidate
#   I want to delete my candidate profile
#   So I can close my account
feature 'Candidate delete', :devise do

  after(:each) do
    Warden.test_reset!
  end

  scenario 'candidate can delete own account' do
    candidate = FactoryGirl.create(:candidate)
    admin = FactoryGirl.create(:admin)
    login_as(admin, scope: :admin)
    visit candidates_path
    click_link(I18n.t('views.common.delete'))
    expect(page).to have_selector('div[id=flash_notice]', text: "Candidate #{candidate.account_name} successfully removed")
  end

end




