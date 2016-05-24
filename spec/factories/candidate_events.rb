FactoryGirl.define do
  factory :candidate_event do
    completed_date nil
    admin_confirmed false
    # after(:build) do |candidate_event|
    #   candidate_event.confirmation_events ||= FactoryGirl.create(:confirmation_event)
    # end
  end
end
