FactoryGirl.define do
  factory :candidate do
    account_name 'sophiaagusta'
    parent_email_1 'test@example.com'
    password 'please123'
    first_name 'Sophia'
    last_name 'Agusta'
    grade 10
    attending 'The Way'
    after(:build) do |candidate|
      candidate.address ||= FactoryGirl.create(:address)
      unless candidate.candidate_events.size > 0
        candidate.candidate_events = create_candidate_events
      end
    end
  end
end

def create_candidate_events
  confirmation_event_eat = ConfirmationEvent.find_by_name('Going out to eat') || FactoryGirl.create(:confirmation_event)
  confirmation_event_home = ConfirmationEvent.find_by_name('Staying home') || FactoryGirl.create(:confirmation_event,
                                                                                                 name: 'Staying home',
                                                                                                 due_date: '2016-04-01',
                                                                                                 instructions: '<h3>Do this</h3><ul><li>one</li><li>two</li><li>three</li></ul></h3>')
  [FactoryGirl.create(:candidate_event,
                      confirmation_event: confirmation_event_eat),
   FactoryGirl.create(:candidate_event,
                      completed_date: '2016-03-29',
                      verified: false,
                      confirmation_event: confirmation_event_home)
  ]
end
