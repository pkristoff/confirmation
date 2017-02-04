include Warden::Test::Helpers
Warden.test_mode!

# Feature: Candidate edit
#   As a candidate
#   I want to edit my candidate profile
#   So I can change my email address
feature 'Candidate event', :devise do

  before(:each) do
    @candidate = FactoryGirl.create(:candidate)
    login_as(@candidate, scope: :candidate)
    @going_out_to_eat_id = @candidate.get_candidate_event('Going out to eat').confirmation_event.id
    @staying_home_id = @candidate.get_candidate_event('Staying home').confirmation_event.id
  end

  after(:each) do
    Warden.test_reset!
  end

  scenario 'candidate changes email address' do
    visit event_candidate_registration_path(@candidate.id)

    # if this passes then going to wrong controller
    expect(page).not_to have_selector('form[id=new_admin]')
    expect_candidate_event(@going_out_to_eat_id, 'Going out to eat', '2016-05-31', nil, 'Do this one two three', false, '', 'div')
    expect_candidate_event(@staying_home_id, 'Staying home', '2016-04-30', nil, 'Do this one two three', false, '2016-03-29', 'div')
  end

  scenario 'candidate changes email address' do
    @candidate.candidate_sheet.attending = I18n.t('model.candidate.attending_catholic_high_school')
    @candidate.save
    visit event_candidate_registration_path(@candidate.id)

    # if this passes then going to wrong controller
    expect(page).not_to have_selector('form[id=new_admin]')
    expect_candidate_event(@going_out_to_eat_id, 'Going out to eat', nil, '2016-05-24', 'Do this one two three', false, '', 'div')
    expect_candidate_event(@staying_home_id, 'Staying home', nil, '2016-04-01', 'Do this one two three', false, '2016-03-29', 'div')
  end

end
