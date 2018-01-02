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
    FactoryBot.create(:candidate, account_name: 'c1')
    FactoryBot.create(:candidate, account_name: 'c3')
    FactoryBot.create(:candidate, account_name: 'c2')
    admin = FactoryBot.create(:admin)
    login_as(admin, scope: :admin)
    # move after FactoryBot create otherwise the events are not picked up.
    AppFactory.add_confirmation_events
    c1 = Candidate.find_by_account_name('c1')
    c2 = Candidate.find_by_account_name('c2')
    c3 = Candidate.find_by_account_name('c3')

    visit candidates_path

    expect(page).to have_css "form[action='/mass_edit_candidates_update']"

    buttons = [
        [AdminsController::DELETE, 'delete'],
        [AdminsController::EMAIL, 'email'],
        [AdminsController::RESET_PASSWORD, 'reset-password'],
        [AdminsController::INITIAL_EMAIL, 'initial-email'],
        [AdminsController::GENERATE_PDF, 'generate-pdf'],
        [AdminsController::CONFIRM_ACCOUNT, 'confirm-account']
    ]

    buttons.each do |button_info|
      const = button_info[0]
      id_suffix = button_info[1]
      expect(page).to have_css("input[type='submit'][value='#{const}']", count: 2)
      expect(page).to have_css("input[id='top-update-#{id_suffix}'][type='submit'][value='#{const}']")
      expect(page).to have_css("input[id='bottom-update-#{id_suffix}'][type='submit'][value='#{const}']")
    end

    expect(page).to have_css("input[type='submit']", count: buttons.size*2)

    expect_sorting_candidate_list(candidates_columns,
                                  [c1, c2, c3],
                                  page)

  end
end