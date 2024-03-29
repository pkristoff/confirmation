# frozen_string_literal: true

describe 'candidates/event.html.erb' do
  include DeviseHelpers
  include ViewsHelpers
  before do
    AppFactory.generate_default_status
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
    @resource.candidate_sheet.attending = Candidate::CATHOLIC_HIGH_SCHOOL
    @resource.save

    login_admin
    allow(controller).to receive(:event_class) { '' }

    render

    expect_confirmation_events(true)
  end

  private

  def expect_confirmation_events(is_chs)
    @resource.candidate_events.each_with_index do |ce, index|
      conf_e = ce.confirmation_event
      expect_candidate_event(index, conf_e.id, conf_e.event_key, (is_chs ? nil : conf_e.the_way_due_date),
                             (is_chs ? conf_e.chs_due_date : nil), conf_e.instructions, false, '', 'fieldset')
    end
  end
end
