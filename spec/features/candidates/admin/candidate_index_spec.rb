include ViewsHelpers
include Warden::Test::Helpers
Warden.test_mode!

# Feature: Candidate index page
#   As a candidate
#   I want to see a list of candidates
#   So I can see who has registered
feature 'Candidate index page', :devise do

  after(:each) do
    Warden.test_reset!
  end

  scenario 'admin can get list of candidates' do
    FactoryGirl.create(:candidate, account_name: 'c1')
    FactoryGirl.create(:candidate, account_name: 'c3')
    FactoryGirl.create(:candidate, account_name: 'c2')
    admin = FactoryGirl.create(:admin)
    login_as(admin, scope: :admin)
    # move after FactoryGirl create otherwise the events are not picked up.
    AppFactory.add_confirmation_events
    c1 = Candidate.find_by_account_name('c1')
    c2 = Candidate.find_by_account_name('c2')
    c3 = Candidate.find_by_account_name('c3')

    visit candidates_path

    expect(page).to have_css "form[action='/mass_edit_candidates_update']"

    expect(page).to have_css("input[type='submit'][value=#{AdminsController::DELETE}]", count: 2)
    expect(page).to have_css("input[type='submit'][value=#{AdminsController::EMAIL}]", count: 2)
    expect(page).to have_css("input[type='submit'][value='#{AdminsController::RESET_PASSWORD}']", count: 2)
    expect(page).to have_css("input[type='submit'][value='#{AdminsController::INITIAL_EMAIL}']", count: 2)


    expect(page).to have_css("input[id='top-update-delete'][type='submit'][value='#{AdminsController::DELETE}']")
    expect(page).to have_css("input[id='top-update-email'][type='submit'][value='#{AdminsController::EMAIL}']")
    expect(page).to have_css("input[id='top-update-reset-password'][type='submit'][value='#{AdminsController::RESET_PASSWORD}']")
    expect(page).to have_css("input[id='top-update-initial-email'][type='submit'][value='#{AdminsController::INITIAL_EMAIL}']")

    expect_sorting_candidate_list(candidates_columns,
                                  [c1, c2, c3],
                                  page)
    expect(page).to have_css("input[id='bottom-update-delete'][type='submit'][value='#{AdminsController::DELETE}']")
    expect(page).to have_css("input[id='bottom-update-email'][type='submit'][value='#{AdminsController::EMAIL}']")
    expect(page).to have_css("input[id='bottom-update-reset-password'][type='submit'][value='#{AdminsController::RESET_PASSWORD}']")
    expect(page).to have_css("input[id='bottom-update-initial-email'][type='submit'][value='#{AdminsController::INITIAL_EMAIL}']")

  end
end