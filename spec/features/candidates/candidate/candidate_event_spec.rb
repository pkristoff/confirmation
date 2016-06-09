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
  end

  after(:each) do
    Warden.test_reset!
  end

  # Scenario: Candidate views own events
  #   Given candidate is signed in
  #   candidate can view own events
  scenario 'candidate changes email address' do
    visit event_candidate_registration_path(@candidate.id)

    # if this passes then going to wrong controller
    expect(page).not_to have_selector('form[id=new_admin]')
    expect_candidate_event 0, 'Going out to eat', '2016-05-24', 'Do this one two three', false, ''
    expect_candidate_event 1, 'Staying home', '2016-04-01', 'Do this one two three', false, ' 2016-03-29'
  end

  def expect_candidate_event(index, name, due_date, instructions, verified, completed_date)
    expect(page).to have_selector("div[id=candidate_event_#{index}_header]", text: name)
    expect(page).to have_selector("div[id=candidate_event_#{index}_due_date]", text: "#{I18n.t('views.events.due_date')}: #{due_date}")
    expect(page).to have_selector("div[id=candidate_event_#{index}_verified]", text: "#{I18n.t('views.events.verified')}: #{verified}")
    expect(page).to have_selector("div[id=candidate_event_#{index}_instructions]", text: "#{I18n.t('views.events.instructions')}: #{instructions}")
    expect(page).to have_selector("div[id=candidate_event_#{index}_completed_date]", text: "#{I18n.t('views.events.completed_date')}:#{completed_date}")
  end

end
