FactoryBot.define do
  factory :candidate_sheet do
    first_name 'Sophia'
    middle_name 'Saraha'
    last_name 'Young'
    after(:build) do |candidate_sheet|
      candidate_sheet.address.street_1 = '555 Xxx Ave.'
      candidate_sheet.address.street_2 = '<nothing>'
      candidate_sheet.address.city = 'Clarksville'
      candidate_sheet.address.state = 'IN'
      candidate_sheet.address.zip_code = '47529'
    end
  end
end
