# frozen_string_literal: true

FactoryBot.define do
  factory :admin, class: Admin do
    name 'Admin Candidate'
    email 'test@example.com'
    password 'please123'
  end
end
