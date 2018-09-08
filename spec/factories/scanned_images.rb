# frozen_string_literal: true

FactoryBot.define do
  factory :scanned_image do
    filename { 'actions.png' }
    content_type { 'image/png' }
    content { 'ZZZ' }
  end
end
