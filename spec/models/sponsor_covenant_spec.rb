# frozen_string_literal: true

require 'rails_helper'

describe SponsorCovenant, type: :model do
  before(:each) do
    @candidate = FactoryBot.create(:candidate)
  end
  describe 'basic creation' do
    it 'can retrieve a SponsorCovenant\'s info' do
      sponsor_covenant = FactoryBot.create(:sponsor_covenant)
      expect(sponsor_covenant.sponsor_name).to match 'George Sponsor'
      expect(sponsor_covenant.scanned_eligibility).to eq(nil)
    end
  end

  describe 'event completion attributes' do
    it 'should return a hash of :attribute => value not including the sponsor church if attends home parish' do
      verifiables = FactoryBot.create(:sponsor_covenant).verifiable_info(@candidate)
      expected_verifiables = { 'Sponsor name': 'George Sponsor',
                               'Sponsor attends': @candidate.home_parish }
      expect(verifiables).to eq(expected_verifiables)
    end
    it 'should return a hash of :attribute => value not including the sponsor church if does not attend home parish' do
      verifiables = FactoryBot.create(:sponsor_covenant,
                                      sponsor_attends_home_parish: false,
                                      sponsor_church: 'St. George the Sponsor').verifiable_info(@candidate)
      expected_verifiables = { 'Sponsor name': 'George Sponsor',
                               'Sponsor attends': 'St. George the Sponsor' }
      expect(verifiables).to eq(expected_verifiables)
    end
  end
end
