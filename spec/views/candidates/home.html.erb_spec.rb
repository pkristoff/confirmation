include DeviseHelpers
include ViewsHelpers

describe 'candidates/home.html.erb' do

  before(:each) do

    @resource_class = Candidate

    @resource = FactoryGirl.create(:candidate)

  end

  it 'Form layout' do

    login_admin

    render

    expect_candidate_event(0, 'Going out to eat', '2016-05-24', 1, '')
    expect_candidate_event(1, 'Staying home', '2016-04-01', 1, '2016-03-29')

  end

  def expect_candidate_event index, name, due_date, admin_confirmed, completed_date
    expect(rendered).to have_selector("fieldset[id=candidate_candidate_events_attributes_#{index}_confirmation_event_attributes_name]", text: name)
    expect(rendered).to have_selector("div[id=candidate_candidate_events_attributes_#{index}_confirmation_event_attributes_due_date]", text: "Due Date : #{due_date}")
    expect(rendered).to have_field("candidate_candidate_events_attributes_#{index}_admin_confirmed", with: admin_confirmed, readonly: false)
    expect(rendered).to have_selector("div[id=candidate_candidate_events_attributes_#{index}_confirmation_event_attributes_completed_date]", text: "Completed : #{completed_date}")
  end
end