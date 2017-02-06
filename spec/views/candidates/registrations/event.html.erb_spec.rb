include DeviseHelpers
include ViewsHelpers

describe 'candidates/registrations/event.html.erb' do

  describe 'Form layout' do

    before(:each) do
      candidate = login_candidate
      @going_out_to_eat_id = candidate.get_candidate_event('Going out to eat').confirmation_event.id
      @staying_home_id = candidate.get_candidate_event('Staying home').confirmation_event.id
    end

    it 'attending == The Way ' do

      allow(controller).to receive(:event_class) { '' }

      render

      expect_candidate_event(0, @going_out_to_eat_id, 'Going out to eat', '2016-05-31', nil, "Do this\none\ntwo\nthree\n\n", false, '', 'div')
      expect_candidate_event(1, @staying_home_id, 'Staying home', '2016-04-30', nil, "Do this\none\ntwo\nthree\n\n", false, '2016-03-29', 'div')

    end

    it 'attending == Catholic High School' do

      candidate = Candidate.find_by_account_name 'sophiaagusta'
      candidate.candidate_sheet.attending = I18n.t('model.candidate.attending_catholic_high_school')
      candidate.save
      allow(controller).to receive(:event_class) { '' }

      render

      expect_candidate_event(0, @going_out_to_eat_id, 'Going out to eat', nil, '2016-05-24', "Do this\none\ntwo\nthree\n\n", false, '', 'div')
      expect_candidate_event(1, @staying_home_id, 'Staying home', nil, '2016-04-01', "Do this\none\ntwo\nthree\n\n", false, '2016-03-29', 'div')

    end

  end
end