# frozen_string_literal: true

Warden.test_mode!

# Feature: Candidate delete
#   As an admin
#   I want to delete candidates

feature 'Candidate delete', :devise do
  include ViewsHelpers
  include Warden::Test::Helpers

  before(:each) do
    FactoryBot.create(:visitor)
    admin = FactoryBot.create(:admin)
    login_as(admin, scope: :admin)

    candidate1 = create_candidate('Vicki', 'Anne', 'Kristoff')
    candidate2 = create_candidate('Paul', 'Richard', 'Kristoff')
    candidate3 = create_candidate('Karen', 'Louise', 'Kristoff')
    AppFactory.add_confirmation_events
    # re-lookup instances are diff
    @candidate1 = Candidate.find_by(account_name: candidate1.account_name)
    @candidate2 = Candidate.find_by(account_name: candidate2.account_name)
    @candidate3 = Candidate.find_by(account_name: candidate3.account_name)
    @candidates = [@candidate1,
                   @candidate2,
                   @candidate3]
  end

  after(:each) do
    Warden.test_reset!
  end

  scenario 'admin cannot delete candidates if none are selected' do
    visit candidates_path
    click_button('top-update-delete')

    expect_message(:flash_alert, I18n.t('messages.no_candidate_selected'))
  end

  scenario 'admin can delete candidates if they are selected' do
    visit candidates_path

    check("candidate_candidate_ids_#{@candidate1.id}")
    check("candidate_candidate_ids_#{@candidate3.id}")
    click_button('top-update-delete')

    expect_message(:flash_notice, I18n.t('messages.candidates_deleted'))
    expect_sorting_candidate_list(
      candidates_columns,
      [@candidate2],
      page
    )
  end
end
