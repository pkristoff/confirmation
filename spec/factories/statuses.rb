# frozen_string_literal: true

FactoryBot.define do
  factory :status do
    name { Status::ACTIVE }
    description { 'factory bot creation' }
  end
end
