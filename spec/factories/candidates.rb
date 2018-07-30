# frozen_string_literal: true

FactoryBot.define do
  factory :candidate do
    transient do
      should_confirm true
      add_candidate_events false
      add_new_confirmation_events true
    end
    account_name 'sophiaagusta'
    password 'please123'
    after(:build) do |candidate, evaluator|
      candidate.confirm if evaluator.should_confirm
      candidate.candidate_sheet.parent_email_1 = 'test@example.com'
      candidate.candidate_sheet.first_name = 'Sophia'
      candidate.candidate_sheet.middle_name = 'Saraha'
      candidate.candidate_sheet.last_name = 'Agusta'
      candidate.candidate_sheet.grade = 10
      candidate.candidate_sheet.attending = I18n.t('model.candidate.attending_the_way')
      # overwrite the already created address
      candidate.candidate_sheet.address&.destroy
      candidate.candidate_sheet.address = FactoryBot.create(:address)
      if evaluator.add_new_confirmation_events && candidate.candidate_events.size <= 0
        candidate.candidate_events = create_candidate_events
      end
      if evaluator.add_candidate_events
        AppFactory.add_candidate_events(candidate)
      end
    end
  end
end

def create_candidate_events
  confirmation_event_eat = ConfirmationEvent.find_by(name: 'Going out to eat') || FactoryBot.create(:confirmation_event)
  confirmation_event_home = ConfirmationEvent.find_by(name: 'Staying home') || FactoryBot.create(:confirmation_event,
                                                                                                 name: 'Staying home',
                                                                                                 the_way_due_date: '2016-04-30',
                                                                                                 chs_due_date: '2016-04-01',
                                                                                                 instructions: '<h3>Do this</h3><ul><li>one</li><li>two</li><li>three</li></ul></h3>')
  [FactoryBot.create(:candidate_event,
                     confirmation_event: confirmation_event_eat),
   FactoryBot.create(:candidate_event,
                     completed_date: '2016-03-29',
                     verified: false,
                     confirmation_event: confirmation_event_home)]
end
