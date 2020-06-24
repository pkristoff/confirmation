# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SponsorEligibility, type: :model do
  it 'check permitted_params' do
    xxx = [:sponsor_attends_home_parish,
           :id,
           :sponsor_church,
           :scanned_eligibility,
           { scanned_eligibility_attributes: %i[filename content_type content id] },
           :sponsor_eligibility_picture,
           :remove_sponsor_eligibility_picture]
    expect(SponsorEligibility.permitted_params).to eq(xxx)
  end
end
