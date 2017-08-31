require 'rails_helper'

describe RetreatVerification, type: :model do

  describe 'basic creation' do

    it 'new can retrieve a RetreatVerification\'s info' do
      retreat_verification = RetreatVerification.new
      retreat_verification.where_held_retreat = 'xxx'
      expect(retreat_verification.where_held_retreat).to match 'xxx'

    end

    it 'FactoryGirl can retrieve a RetreatVerification\'s info' do
      retreat_verification = FactoryGirl.create(:retreat_verification)
      expect(retreat_verification.where_held_retreat).to match 'Here'
      expect(retreat_verification.filename).to eq('actions.png')

    end

  end

  describe 'event completion attributes' do
    it 'should return a hash of :attribute => value' do
      candidate = FactoryGirl.create(:candidate)
      verifiables = FactoryGirl.create(:retreat_verification).verifiable_info(candidate)
      expected_verifiables = {}
      expect(verifiables).to eq(expected_verifiables)
    end
  end

end
