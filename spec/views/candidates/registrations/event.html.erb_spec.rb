include DeviseHelpers
include ViewsHelpers

describe 'candidates/registrations/event.html.erb' do

  describe 'Form layout' do

    it 'attending == The Way ' do

      login_candidate
      allow(controller).to receive(:event_class) { '' }

      render

      expect_candidate_event(0, 'Going out to eat', '2016-05-31', nil, "Do this\none\ntwo\nthree\n\n", false, '', 'div')
      expect_candidate_event(1, 'Staying home', '2016-04-30', nil, "Do this\none\ntwo\nthree\n\n", false, '2016-03-29', 'div')

    end

    it 'attending == Catholic High School' do

      login_candidate
      candidate = Candidate.find_by_account_name 'sophiaagusta'
      candidate.candidate_sheet.attending = I18n.t('model.candidate.attending_catholic_high_school')
      candidate.save
      allow(controller).to receive(:event_class) { '' }

      render

      expect_candidate_event(0, 'Going out to eat', nil, '2016-05-24', "Do this\none\ntwo\nthree\n\n", false, '', 'div')
      expect_candidate_event(1, 'Staying home', nil, '2016-04-01', "Do this\none\ntwo\nthree\n\n", false, '2016-03-29', 'div')

    end

  end
end