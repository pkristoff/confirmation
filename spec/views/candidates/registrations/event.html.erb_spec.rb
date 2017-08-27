include DeviseHelpers
include ViewsHelpers

describe 'candidates/registrations/event.html.erb' do

  describe 'Form layout' do

    before(:each) do
      candidate = login_candidate
      AppFactory.add_confirmation_events
    end

    it 'attending == The Way ' do

      allow(controller).to receive(:event_class) { '' }

      render

      expect_confirmation_events(false)

    end

    it 'attending == Catholic High School' do

      candidate = Candidate.find_by_account_name 'sophiaagusta'
      candidate.candidate_sheet.attending = I18n.t('model.candidate.attending_catholic_high_school')
      candidate.save
      allow(controller).to receive(:event_class) { '' }

      render

      expect_confirmation_events(true)

    end

  end

  def expect_confirmation_events(is_chs)

    ConfirmationEvent.all.each_with_index  do |ce,index|
      expect_candidate_event(index+3, ce.id, ce.name, (is_chs ? nil : ce.the_way_due_date), (is_chs ? ce.chs_due_date : nil), ce.instructions, false, '', 'div')

    end
  end
end