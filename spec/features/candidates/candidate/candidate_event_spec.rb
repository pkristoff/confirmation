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
    expect(page).not_to have_selector("form[id=new_admin]")
    expect_event 0, 'Going out to eat', 'Due Date : 2016-05-24', 1, 'Completed :'
    expect_event 1, 'Staying home', 'Due Date : 2016-04-01', 1, 'Completed : 2016-03-29'
  end

  def expect_event index, title, due_date, admin_confirmed, completed_date
    expect(page).to have_selector("fieldset[id=candidate_candidate_events_attributes_#{index}_confirmation_event_attributes_name]", text: title)
    expect(page).to have_selector("div[id=candidate_candidate_events_attributes_#{index}_confirmation_event_attributes_due_date]", text: due_date)
    expect(page).to have_field("candidate_candidate_events_attributes_#{index}_admin_confirmed", with: admin_confirmed)
    expect(page).to have_selector("div[id=candidate_candidate_events_attributes_#{index}_confirmation_event_attributes_completed_date]", text: completed_date)
  end

end
