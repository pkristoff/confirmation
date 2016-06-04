include DeviseHelpers
include ViewsHelpers

describe 'candidates/event.html.erb' do

  before(:each) do

    @resource_class = Candidate

    @resource = FactoryGirl.create(:candidate)

  end

  it 'Form layout' do

    login_admin
    allow(controller).to receive(:event_class) { '' }

    render

    expect_candidate_event(0, 'Going out to eat', '2016-05-24', false, '')
    expect_candidate_event(1, 'Staying home', '2016-04-01', false, '2016-03-29')

  end

  def expect_candidate_event index, name, due_date, admin_confirmed, completed_date
    expect(rendered).to have_selector("fieldset[id=candidate_candidate_events_attributes_#{index}_confirmation_event_attributes_name]", text: name)
    expect(rendered).to have_selector("div[id=candidate_candidate_events_attributes_#{index}_confirmation_event_attributes_due_date]", text: "Due date: #{due_date}")
    if admin_confirmed
      expect(rendered).to have_field("candidate_candidate_events_attributes_#{index}_admin_confirmed", checked: true)
    else
      expect(rendered).to have_field("candidate_candidate_events_attributes_#{index}_admin_confirmed", unchecked: true)
    end

    if completed_date.empty?
      expect(rendered).to have_field("candidate_candidate_events_attributes_#{index}_completed_date")
    else
      expect(rendered).to have_field("candidate_candidate_events_attributes_#{index}_completed_date", with: completed_date.strip)
    end
  end
end