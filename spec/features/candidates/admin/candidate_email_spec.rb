include ViewsHelpers
include Warden::Test::Helpers
Warden.test_mode!

feature 'Candidate email', :devise do

  before(:each) do

    admin = FactoryGirl.create(:admin)
    login_as(admin, scope: :admin)

    @candidate_1 = create_candidate('Vicki', 'Anne', 'Kristoff')
    @candidate_2 = create_candidate('Paul', 'Richard', 'Kristoff')
    @candidate_3 = create_candidate('Karen', 'Louise', 'Kristoff')
    @candidates = [@candidate_1, @candidate_2, @candidate_3]

    AppFactory.add_confirmation_events

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

    check("candidate_candidate_ids_#{@candidate_1.id}")
    check("candidate_candidate_ids_#{@candidate_3.id}")
    click_button('top-update-email')

    expect_mass_mailing_html([@candidate_1, @candidate_2, @candidate_3], page)

    expect(page).to have_checked_field("candidate_candidate_ids_#{@candidate_1.id}")
    expect(page).to have_checked_field("candidate_candidate_ids_#{@candidate_3.id}")

  end

end




