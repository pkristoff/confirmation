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
    it 'program_year = 1' do
      program_year = 1
      @resource.candidate_sheet.program_year = program_year
      @resource.save!
      login_admin
      allow(controller).to receive(:event_class) { '' }

      render

      expect_confirmation_events(program_year == 2)
    end
  end

  it 'program_year = 2' do
    program_year = 2
    @resource.candidate_sheet.program_year = program_year
    @resource.save

    login_admin
    allow(controller).to receive(:event_class) { '' }

    render

    expect_confirmation_events(program_year == 2)
  end

  private

  def expect_confirmation_events(is_program_year2)
    @resource.candidate_events.each_with_index do |ce, index|
      conf_e = ce.confirmation_event
      expect_candidate_event(index, conf_e.id, conf_e.event_key, (is_program_year2 ? nil : conf_e.program_year1_due_date),
                             (is_program_year2 ? conf_e.program_year2_due_date : nil), conf_e.instructions, false, '', 'fieldset')
    end
  end
end
