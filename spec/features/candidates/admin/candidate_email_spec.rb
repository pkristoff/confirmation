# frozen_string_literal: true

Warden.test_mode!

feature 'Candidate email', :devise do
  include ViewsHelpers
  include Warden::Test::Helpers

  before(:each) do
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

  scenario 'admin cannot email candidates if none are selected' do
    visit candidates_path
    click_button('top-update-email')

    expect_message(:flash_alert, I18n.t('messages.no_candidate_selected'))
  end

  scenario 'admin can email candidates if they are selected' do
    visit candidates_path

    check("candidate_candidate_ids_#{@candidate1.id}")
    check("candidate_candidate_ids_#{@candidate3.id}")
    click_button('top-update-email')

    expect_mass_mailing_html([@candidate1, @candidate2, @candidate3], page)

    expect(page).to have_checked_field("candidate_candidate_ids_#{@candidate1.id}")
    expect(page).to have_checked_field("candidate_candidate_ids_#{@candidate3.id}")
  end
end
