# frozen_string_literal: true

describe 'candidates/registrations/event.html.erb' do
  include DeviseHelpers
  include ViewsHelpers
  describe 'Form layout' do
    before(:each) do
      login_candidate
      AppFactory.add_confirmation_events
    end

    it 'attending == The Way ' do
      allow(controller).to receive(:event_class) { '' }

      render

      expect_confirmation_events(false)
    end

    it 'attending == Catholic High School' do
      candidate = Candidate.find_by account_name: 'sophiaagusta'
      candidate.candidate_sheet.attending = I18n.t('model.candidate.attending_catholic_high_school')
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
        expect(rendered).to have_css('h3', text: I18n.t('events.parent_meeting')) if event_key == Candidate.parent_meeting_event_key
        expect(rendered).to have_css('a', text: Candidate.i18n_event_name(event_key)) unless event_key == Candidate.parent_meeting_event_key
        count += 1
      end
      expect(count).to eq(AppFactory.all_i18n_confirmation_event_keys.size)
    end
  end

  def expect_confirmation_events(is_chs)
    ConfirmationEvent.all.each_with_index do |ce, index|
      expect_candidate_event(index + 3, ce.id, ce.event_key, (is_chs ? nil : ce.the_way_due_date), (is_chs ? ce.chs_due_date : nil), ce.instructions, false, '', 'div')
    end
  end
end
