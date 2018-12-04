# frozen_string_literal: true

FactoryBot.define do
  factory :candidate_sheet do
    first_name { 'Sophia' }
    middle_name { 'Saraha' }
    last_name { 'Young' }
    parent_email_1 { 'goo@foo.com' }
    after(:build) do |candidate_sheet|
      candidate_sheet.address.street_1 = '555 Xxx Ave.'
      candidate_sheet.address.street_2 = '<nothing>'
      candidate_sheet.address.city = 'Clarksville'
      candidate_sheet.address.state = 'IN'
      candidate_sheet.address.zip_code = '47529'
    end
  end
end
