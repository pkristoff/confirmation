include DeviseHelpers
include ViewsHelpers

describe 'candidates/event.html.erb' do

  before(:each) do

    @resource_class = Candidate

    @resource = FactoryGirl.create(:candidate)

    @going_event_id = @resource.get_candidate_event('Going out to eat').id
    @staying_event_id = @resource.get_candidate_event('Staying home').id

  end

  describe 'Form layout' do

    it 'attending The Way' do

      login_admin
      allow(controller).to receive(:event_class) { '' }

      render

      expect_candidate_event(0, @going_event_id, 'Going out to eat', '2016-05-31', nil, '', false, '')
      expect_candidate_event(1, @staying_event_id, 'Staying home', '2016-04-30', nil, '', false, '2016-03-29')

    end

  end

  it 'attending Catholic High School' do

    @resource.candidate_sheet.attending = I18n.t('model.candidate.attending_catholic_high_school')
    @resource.save

    login_admin
    allow(controller).to receive(:event_class) { '' }

    render

    expect_candidate_event(0, @going_event_id, 'Going out to eat', nil, '2016-05-24', '', false, '')
    expect_candidate_event(1, @staying_event_id, 'Staying home', nil, '2016-04-01', '', false, '2016-03-29')

  end

end