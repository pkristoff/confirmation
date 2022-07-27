# frozen_string_literal: true

FactoryBot.define do
  factory :visitor do
    home_parish { 'St. Mary Magdalene' }
    home { '<p>home text</p>' }
    about { '<p>about text</p>' }
    contact { '<p>contact me</p>' }
    after(:build) do |visitor|
      visitor.home_parish_address.street_1 = '555 MM Way'
      visitor.home_parish_address.street_2 = '<nothing>'
      visitor.home_parish_address.city = 'Apex'
      visitor.home_parish_address.state = 'NC'
      visitor.home_parish_address.zip_code = '27502'
    end
  end
end
