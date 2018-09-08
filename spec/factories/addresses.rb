# frozen_string_literal: true

FactoryBot.define do
  factory :address do
    street_1 { '2120 Frissell Ave.' }
    street_2 { 'Apt. 456' }
    city { 'Apex' }
    state { 'NC' }
    zip_code { '27502' }
  end
end
