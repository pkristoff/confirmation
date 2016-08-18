include DeviseHelpers
include ViewsHelpers

describe 'candidates/registrations/event.html.erb' do

  it 'Form layout' do

    login_candidate
    allow(controller).to receive(:event_class) { '' }

    render

    expect_candidate_event(0, 'Going out to eat', '2016-05-31', '2016-05-24', "Do this\none\ntwo\nthree\n\n", false, '')
    expect_candidate_event(1, 'Staying home', '2016-04-30', '2016-04-01', "Do this\none\ntwo\nthree\n\n", false, '2016-03-29')

  end

  def expect_candidate_event(index, name, the_way_due_date, chs_due_date, instructions, verified, completed_date)

    expect(rendered).to have_selector("div[id=candidate_event_#{index}_header]", text: name)
    expect(rendered).to have_selector("div[id=candidate_event_#{index}_the_way_due_date]", text: "#{I18n.t('views.events.the_way_due_date')}: #{the_way_due_date}")
    expect(rendered).to have_selector("div[id=candidate_event_#{index}_chs_due_date]", text: "#{I18n.t('views.events.chs_due_date')}: #{chs_due_date}")
    expect(rendered).to have_selector("div[id=candidate_event_#{index}_instructions]", text: "#{I18n.t('views.events.instructions')}:")
    expect(rendered).to have_selector("div[id=candidate_event_#{index}_instructions]", text: "#{instructions}")
    expect(rendered).to have_selector("div[id=candidate_event_#{index}_verified]", text: "#{I18n.t('views.events.verified')}: #{verified}")
    expect(rendered).to have_selector("div[id=candidate_event_#{index}_completed_date]", text: "#{I18n.t('views.events.completed_date')}: #{completed_date}")
  end
end