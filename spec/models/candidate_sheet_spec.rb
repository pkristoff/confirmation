require 'rails_helper'

describe CandidateSheet, type: :model do

  describe 'basic creation' do

    it 'new can retrieve a CandidateSheet\'s info' do
      candidate_sheet = CandidateSheet.new
      candidate_sheet.first_name = 'xxx'
      expect(candidate_sheet.first_name).to match 'xxx'

    end

    it 'new can retrieve a CandidateSheet\'s middle_name' do
      candidate_sheet = CandidateSheet.new
      candidate_sheet.middle_name = 'xxx'
      expect(candidate_sheet.middle_name).to match 'xxx'

    end

    it 'FactoryGirl can retrieve a ChristianMinistry\'s info' do
      candidate_sheet = FactoryGirl.create(:candidate_sheet)
      expect(candidate_sheet.first_name).to match 'Sophia'
      expect(candidate_sheet.middle_name).to match 'Saraha'
      expect(candidate_sheet.last_name).to match 'Young'
      expect(candidate_sheet.address).not_to eq(nil)

    end

  end

  describe 'event completion attributes' do
    it 'should return a hash of :attribute => value' do
      verifiables = FactoryGirl.create(:candidate_sheet).verifiable_info
      expected_verifiables = {name: 'Sophia Young', grade: 10, street_1: '555 Xxx Ave.', street_2: '<nothing>', city: 'Clarksville', state: 'IN', zipcode: '47529'}
      expect(verifiables).to eq(expected_verifiables)
    end
  end
end