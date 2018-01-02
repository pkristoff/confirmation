include DeviseHelpers
include ViewsHelpers

describe 'candidates/event.html.erb' do

  before(:each) do

    @resource_class = Candidate

    candidate = FactoryBot.create(:candidate)
    AppFactory.add_confirmation_events
    @resource = Candidate.find(candidate.id)


  end

  describe 'Form layout' do

    it 'attending The Way' do

      login_admin
      allow(controller).to receive(:event_class) { '' }

      render

      expect_confirmation_events(false)

    end

  end

  it 'attending Catholic High School' do

    @resource.candidate_sheet.attending = I18n.t('model.candidate.attending_catholic_high_school')
    @resource.save

    login_admin
    allow(controller).to receive(:event_class) { '' }

    render


    expect_confirmation_events(true)

  end

  def expect_confirmation_events(is_chs)

    @resource.candidate_events.each_with_index  do |ce,index|
      conf_e = ce.confirmation_event
      expect_candidate_event(index, conf_e.id, conf_e.name, (is_chs ? nil : conf_e.the_way_due_date), (is_chs ? conf_e.chs_due_date : nil), conf_e.instructions, false, '', 'fieldset')

    end
  end

end