# frozen_string_literal: true

Warden.test_mode!

# Feature: Candidate index page
#   As a candidate
#   I want to see a list of candidates
#   So I can see who has registered
feature 'Candidate index page', :devise do
  include ViewsHelpers
  include Warden::Test::Helpers

  before do
    FactoryBot.create(:visitor)
  end

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
    c1 = Candidate.find_by(account_name: 'c1')
    c2 = Candidate.find_by(account_name: 'c2')
    c3 = Candidate.find_by(account_name: 'c3')

    visit candidates_path

    expect(page).to have_css "form[action='/mass_edit_candidates_update']"

    buttons = [
      [AdminsController::DELETE, 'delete', I18n.t('views.common.delete')],
      [AdminsController::EMAIL, 'email', I18n.t('views.common.email')],
      [AdminsController::RESET_PASSWORD, 'reset_password', I18n.t('views.common.reset_password')],
      [AdminsController::INITIAL_EMAIL, 'initial_email', I18n.t('views.common.initial_email')],
      [AdminsController::GENERATE_PDF, 'generate_pdf', I18n.t('views.common.generate_pdf')],
      [AdminsController::CONFIRM_ACCOUNT, 'confirm_account', I18n.t('views.common.confirm_account')],
      [AdminsController::UNCONFIRM_ACCOUNT, 'unconfirm_account', I18n.t('views.common.unconfirm_account')]
    ]

    buttons.each do |button_info|
      const = button_info[0]
      id_suffix = button_info[1]
      text = button_info[2]

      expect(page).to have_css("button[type='submit'][value='#{const}']", count: 2)
      expect(page).to have_css("button[id='top-update-#{id_suffix}'][type='submit'][value='#{const}']", text: text)
      expect(page).to have_css("button[id='bottom-update-#{id_suffix}'][type='submit'][value='#{const}']", text: text)
    end

    expect(page).to have_css("button[type='submit']", count: buttons.size * 2)

    expect_sorting_candidate_list(candidates_columns,
                                  [c1, c2, c3],
                                  page)
  end
end
