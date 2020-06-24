# frozen_string_literal: true

FactoryBot.define do
  factory :sponsor_eligibility do
    sponsor_attends_home_parish { true }
  end
end
