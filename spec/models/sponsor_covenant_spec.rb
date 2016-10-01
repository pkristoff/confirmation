require 'rails_helper'

describe SponsorCovenant, type: :model do

  describe 'basic creation' do

    it 'can retrieve a SponsorCovenant\'s info' do
      sponsor_covenant = FactoryGirl.create(:sponsor_covenant)
      expect(sponsor_covenant.sponsor_name).to match 'George Sponsor'
      expect(sponsor_covenant.sponsor_elegibility_filename).to eq(nil)

    end

  end

  describe 'event completion attributes' do
    it 'should return a hash of :attribute => value not including the sponsor church if attends St. mm' do
      verifiables = FactoryGirl.create(:sponsor_covenant).verifiable_info
      expected_verifiables = {'Sponsor name': 'George Sponsor',
                              'Sponsor attends': 'St. Mary Magdalene'}
      expect(verifiables).to eq(expected_verifiables)
    end
    it 'should return a hash of :attribute => value not including the sponsor church if does not attend St. MM' do
      verifiables = FactoryGirl.create(:sponsor_covenant,
                                       sponsor_attends_stmm: false,
                                       sponsor_church: 'St. George the Sponsor').verifiable_info
      expected_verifiables = {'Sponsor name': 'George Sponsor',
                              'Sponsor attends': 'St. George the Sponsor'}
      expect(verifiables).to eq(expected_verifiables)
    end
  end
end
