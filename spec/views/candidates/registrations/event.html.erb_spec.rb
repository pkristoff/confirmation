include DeviseHelpers
include ViewsHelpers

describe 'candidates/registrations/event.html.erb' do

  it 'Form layout' do

    login_candidate
    allow(controller).to receive(:event_class) { '' }

    render

    expect_candidate_event(0, 'Going out to eat', '2016-05-24', false, '')
    expect_candidate_event(1, 'Staying home', '2016-04-01', false, '2016-03-29')

  end

  def expect_candidate_event(index, name, due_date, verified, completed_date)

    expect(rendered).to have_selector("div[id=candidate_event_#{index}_header]", text: name)
    expect(rendered).to have_selector("div[id=candidate_event_#{index}_due_date]", text: "#{I18n.t('views.events.due_date')}: #{due_date}")
    expect(rendered).to have_selector("div[id=candidate_event_#{index}_verified]", text: "#{I18n.t('views.events.verified')}: #{verified}")
    expect(rendered).to have_selector("div[id=candidate_event_#{index}_completed_date]", text: "#{I18n.t('views.events.completed_date')}: #{completed_date}")
  end
end