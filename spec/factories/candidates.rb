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
  [FactoryGirl.create(:candidate_event,
                      confirmation_event: FactoryGirl.create(:confirmation_event)),
   FactoryGirl.create(:candidate_event,
                      completed_date: '2016-03-29',
                      admin_confirmed: false,
                      confirmation_event: FactoryGirl.create(:confirmation_event,
                                                             name: 'Staying home',
                                                             due_date: '2016-04-01'))
  ]
end
