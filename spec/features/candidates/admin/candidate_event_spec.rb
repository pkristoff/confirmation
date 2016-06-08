include Warden::Test::Helpers
Warden.test_mode!

# Feature: Candidate edit
#   As a candidate
#   I want to edit my candidate profile
#   So I can change my email address
feature 'Candidate event', :devise do

  before(:each) do
    @admin = FactoryGirl.create(:admin)
    login_as(@admin, scope: :admin)
  end

  after(:each) do
    Warden.test_reset!
  end

  # Scenario: Admin views candidate's events
  #   Given admin is signed in
  #   admin can view candidate's events
  scenario 'candidate changes email address' do
    candidate = FactoryGirl.create(:candidate)
    visit event_candidate_path(candidate.id)

    # if this fails then going to wrong controller
    expect(page).not_to have_selector("form[id=new_admin]")
    expect_candidate_event 0, 'Going out to eat', '2016-05-24', false, ''
    expect_candidate_event 1, 'Staying home', '2016-04-01', false, ' 2016-03-29'
  end

  def expect_candidate_event(index, name, due_date, verified, completed_date)
    expect(page).to have_selector("fieldset[id=candidate_candidate_events_attributes_#{index}_confirmation_event_attributes_name]", text: name)
    expect(page).to have_selector("div[id=candidate_candidate_events_attributes_#{index}_confirmation_event_attributes_due_date]", text: "#{I18n.t('views.events.due_date')}: #{due_date}")
    if verified
      expect(page).to have_field("candidate_candidate_events_attributes_#{index}_verified", checked: true)
    else
      expect(page).to have_field("candidate_candidate_events_attributes_#{index}_verified", unchecked: true)
    end

    if completed_date.empty?
      expect(page).to have_field("candidate_candidate_events_attributes_#{index}_completed_date")
    else
      expect(page).to have_field("candidate_candidate_events_attributes_#{index}_completed_date", with: completed_date.strip)
    end
  end

end
