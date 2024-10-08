# frozen_string_literal: true

describe 'candidates/registrations/event.html.erb' do
  include DeviseHelpers
  include ViewsHelpers
  describe 'Form layout' do
    before do
      login_candidate
      AppFactory.add_confirmation_events
    end

    it 'program_year == 1' do
      program_year = 1
      candidate = Candidate.find_by account_name: 'sophiaagusta'
      candidate.candidate_sheet.program_year = program_year
      candidate.save
      allow(controller).to receive(:event_class) { '' }

      render

      expect_confirmation_events(false)
    end

    it 'program_year = 2' do
      program_year = 2
      candidate = Candidate.find_by account_name: 'sophiaagusta'
      candidate.candidate_sheet.program_year = program_year
      candidate.save
      allow(controller).to receive(:event_class) { '' }

      render

      expect_confirmation_events(true)
    end

    it 'links for all events except for parent information meeting' do
      allow(controller).to receive(:event_class) { '' }

      render

      count = 0
      AppFactory.all_i18n_confirmation_event_keys.each do |event_key|
        guard = event_key == Candidate.parent_meeting_event_key
        expect(rendered).to have_css('h3', text: I18n.t('events.parent_meeting')) if guard
        expect(rendered).to have_css('a', text: Candidate.i18n_event_name(event_key)) unless guard
        count += 1
      end
      expect(count).to eq(AppFactory.all_i18n_confirmation_event_keys.size)
    end
  end

  private

  def expect_confirmation_events(is_chs)
    ConfirmationEvent.all.each_with_index do |ce, index|
      expect_candidate_event(index + 3, ce.id, ce.event_key,
                             (is_chs ? nil : ce.program_year1_due_date),
                             (is_chs ? ce.program_year2_due_date : nil),
                             ce.instructions, false, '', 'div')
    end
  end
end
