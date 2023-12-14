# frozen_string_literal: true

require 'rails_helper'

describe SponsorCovenant do
  before do
    AppFactory.generate_default_status
    @candidate = FactoryBot.create(:candidate)
  end

  describe 'basic creation' do
    it 'can retrieve a SponsorCovenant\'s info' do
      sponsor_covenant = FactoryBot.create(:sponsor_covenant)
      expect(sponsor_covenant.sponsor_name).to match 'George Sponsor'
      expect(sponsor_covenant.scanned_covenant).to be_nil
    end
  end

  describe 'event completion attributes' do
    it 'return a hash of :attribute => value not including the sponsor church if attends home parish' do
      verifiables = FactoryBot.create(:sponsor_covenant).verifiable_info
      expected_verifiables = { 'Sponsor name': 'George Sponsor' }
      expect(verifiables).to eq(expected_verifiables)
    end
  end
end
