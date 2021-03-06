# frozen_string_literal: true

FactoryBot.define do
  factory :retreat_verification do
    retreat_held_at_home_parish { false }
    start_date { '2017-02-06' }
    end_date { '2017-02-06' }
    who_held_retreat { 'I did' }
    where_held_retreat { 'Here' }
    after(:build) do |retreat, _evaluator|
      retreat.scanned_retreat = FactoryBot.create(:scanned_image,
                                                  filename: 'actions.png',
                                                  content_type: 'image/png',
                                                  content: 'WWW')
    end
  end
end
