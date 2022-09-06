# frozen_string_literal: true

FactoryBot.define do
  factory :candidate_sheet do
    first_name { 'Sophia' }
    middle_name { 'Saraha' }
    last_name { 'Young' }
    parent_email_1 { 'goo@foo.com' }
  end
end
