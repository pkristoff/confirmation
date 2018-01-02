include ViewsHelpers
include Warden::Test::Helpers
Warden.test_mode!

# Feature: Candidate delete
#   As an admin
#   I want to delete candidates

feature 'Candidate delete', :devise do

  before(:each) do

    admin = FactoryBot.create(:admin)
    login_as(admin, scope: :admin)

    candidate_1 = create_candidate('Vicki', 'Anne', 'Kristoff')
    candidate_2 = create_candidate('Paul', 'Richard', 'Kristoff')
    candidate_3 = create_candidate('Karen', 'Louise', 'Kristoff')
    AppFactory.add_confirmation_events
    # re-lookup instances are diff
    @candidate_1 = Candidate.find_by_account_name(candidate_1.account_name)
    @candidate_2 = Candidate.find_by_account_name(candidate_2.account_name)
    @candidate_3 = Candidate.find_by_account_name(candidate_3.account_name)
    @candidates = [@candidate_1,
                   @candidate_2,
                   @candidate_3
    ]

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

    check("candidate_candidate_ids_#{@candidate_1.id}")
    check("candidate_candidate_ids_#{@candidate_3.id}")
    click_button('top-update-delete')

    expect_message(:flash_notice, I18n.t('messages.candidates_deleted'))
    expect_sorting_candidate_list(
        candidates_columns,
        [@candidate_2],
        page)
  end

end




