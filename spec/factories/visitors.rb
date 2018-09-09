# frozen_string_literal: true

FactoryBot.define do
  factory :visitor do
    home { '<p>home text</p>' }
    about { '<p>about text</p>' }
    contact { '<p>contact me</p>' }
  end
end
