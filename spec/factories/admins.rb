# frozen_string_literal: true

FactoryBot.define do
  factory :admin, class: 'Admin' do
    account_name { 'Admin' }
    name { 'Admin Candidate' }
    email { 'test@example.com' }
    contact_name { 'Vicki Kristoff' }
    contact_phone { '919-249-5629' }
    password { 'please123' }
  end
end
