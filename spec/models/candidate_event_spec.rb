require 'rails_helper'

RSpec.describe CandidateEvent, type: :model do
  it 'basic creation' do

    confirmation_event = FactoryGirl.create(:confirmation_event)
    candidate_event = FactoryGirl.create(:candidate_event,
                                         completed_date: '2016-05-23',
                                         admin_confirmed: true,
                                         confirmation_event: confirmation_event)

    expect(candidate_event.completed_date.to_s).to eq('2016-05-23')
    expect(candidate_event.admin_confirmed).to eq(true)

    expect(candidate_event.due_date.to_s).to eq('2016-05-24')
    expect(candidate_event.name).to eq('Going out to eat')

    expect_confirmation_event(confirmation_event, 1)

  end
  it 'two candidate_events same confirmation_event' do

    confirmation_event = FactoryGirl.create(:confirmation_event)
    candidate_event = FactoryGirl.create(:candidate_event,
                                         completed_date: '2016-05-23',
                                         admin_confirmed: true,
                                         confirmation_event: confirmation_event)
    candidate_event_2 = FactoryGirl.create(:candidate_event,
                                           completed_date: '2016-05-22',
                                           admin_confirmed: false,
                                           confirmation_event: confirmation_event)

    expect(candidate_event.completed_date.to_s).to eq('2016-05-23')
    expect(candidate_event.admin_confirmed).to eq(true)

    expect(candidate_event.due_date.to_s).to eq('2016-05-24')
    expect(candidate_event.name).to eq('Going out to eat')

    expect(candidate_event_2.completed_date.to_s).to eq('2016-05-22')
    expect(candidate_event_2.admin_confirmed).to eq(false)

    expect(candidate_event_2.due_date.to_s).to eq('2016-05-24')
    expect(candidate_event_2.name).to eq('Going out to eat')

    expect_confirmation_event(confirmation_event, 2)
    expect(candidate_event.confirmation_event).to eq(candidate_event_2.confirmation_event)

  end
  it 'two candidate_events with different confirmation_events' do

    confirmation_event = FactoryGirl.create(:confirmation_event)
    confirmation_event_2 = FactoryGirl.create(:confirmation_event,
                                              name: 'Staying home',
                                              due_date: '2016-04-01')
    candidate_event = FactoryGirl.create(:candidate_event,
                                         completed_date: '2016-05-23',
                                         admin_confirmed: true,
                                         confirmation_event: confirmation_event)
    candidate_event_2 = FactoryGirl.create(:candidate_event,
                                           completed_date: '2016-05-22',
                                           admin_confirmed: false,
                                           confirmation_event: confirmation_event_2)

    expect(candidate_event.completed_date.to_s).to eq('2016-05-23')
    expect(candidate_event.admin_confirmed).to eq(true)

    expect(candidate_event.due_date.to_s).to eq('2016-05-24')
    expect(candidate_event.name).to eq('Going out to eat')

    expect(candidate_event_2.completed_date.to_s).to eq('2016-05-22')
    expect(candidate_event_2.admin_confirmed).to eq(false)

    expect(candidate_event_2.due_date.to_s).to eq('2016-04-01')
    expect(candidate_event_2.name).to eq('Staying home')

    expect_confirmation_event(confirmation_event, 1)
    expect_confirmation_event(confirmation_event_2, 1, '2016-04-01', 'Staying home')
    expect(candidate_event.confirmation_event).not_to eq(candidate_event_2.confirmation_event)

  end

  def expect_confirmation_event(confirmation_event, candidate_events_size, due_date='2016-05-24', name='Going out to eat')
    expect(confirmation_event.due_date.to_s).to eq(due_date)
    expect(confirmation_event.name).to eq(name)
    expect(confirmation_event.candidate_events.size).to eq(candidate_events_size)
  end
end
