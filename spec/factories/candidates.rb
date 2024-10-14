# frozen_string_literal: true

FactoryBot.define do
  factory :candidate do
    transient do
      should_confirm { true }
      add_candidate_events { false }
      add_new_confirmation_events { true }
    end
    account_name { 'augustasophia' }
    password { 'please123' }
    candidate_note { 'Admin note' }
    after(:build) do |candidate, evaluator|
      # AppFactory.generate_default_status unless Status.active
      raise('Need to create Active status before candidate') unless Status.active

      candidate.status_id = Status.active.id if Status.active

      candidate.confirm if evaluator.should_confirm
      candidate.candidate_sheet.parent_email_1 = 'test@example.com'
      candidate.candidate_sheet.first_name = 'Sophia'
      candidate.candidate_sheet.middle_name = 'Saraha'
      candidate.candidate_sheet.last_name = 'Augusta'
      candidate.candidate_sheet.grade = 10
      candidate.candidate_sheet.attending = Candidate::THE_WAY
      pred = evaluator.add_new_confirmation_events && candidate.candidate_events.size <= 0
      candidate.candidate_events = create_candidate_events if pred

      AppFactory.add_candidate_events(candidate) if evaluator.add_candidate_events
    end
  end
end

private

def create_candidate_events
  confirmation_event_eat = ConfirmationEvent.find_by(event_key: 'Going out to eat') || FactoryBot.create(:confirmation_event)
  instructions = '<h3>Do this</h3><ul><li>one</li><li>two</li><li>three</li></ul></h3>'
  confirmation_event_home =
    ConfirmationEvent.find_by(event_key: 'Staying home') || FactoryBot.create(:confirmation_event,
                                                                              event_key: 'Staying home',
                                                                              program_year1_due_date: '2016-04-30',
                                                                              program_year2_due_date: '2016-04-01',
                                                                              instructions: instructions)
  [FactoryBot.create(:candidate_event,
                     confirmation_event: confirmation_event_eat),
   FactoryBot.create(:candidate_event,
                     completed_date: '2016-03-29',
                     verified: false,
                     confirmation_event: confirmation_event_home)]
end
