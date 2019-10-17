# frozen_string_literal: true

FactoryBot.define do
  factory :sponsor_covenant do
    sponsor_name { 'George Sponsor' }
    sponsor_attends_home_parish { true }
  end
end
