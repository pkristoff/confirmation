require 'rails_helper'

describe CandidateSheet, type: :model do

  describe 'basic creation' do

    it 'new can retrieve a CandidateSheet\'s info' do
      candidate_sheet = CandidateSheet.new
      candidate_sheet.first_name = 'xxx'
      expect(candidate_sheet.first_name).to match 'xxx'

    end

    it 'FactoryGirl can retrieve a ChristianMinistry\'s info' do
      candidate_sheet = FactoryGirl.create(:candidate_sheet)
      expect(candidate_sheet.first_name).to match 'Sophia'
      expect(candidate_sheet.last_name).to match 'Young'
      expect(candidate_sheet.address).not_to eq(nil)

    end

  end
end