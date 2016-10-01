require 'rails_helper'

describe ChristianMinistry, type: :model do

  describe 'basic creation' do

    it 'new can retrieve a ChristianMinistry\'s info' do
      christian_ministry = ChristianMinistry.new
      christian_ministry.what_service = 'xxx'
      expect(christian_ministry.what_service).to match 'xxx'

    end

    it 'FactoryGirl can retrieve a ChristianMinistry\'s info' do
      christian_ministry = FactoryGirl.create(:christian_ministry)
      expect(christian_ministry.what_service).to match 'Helped some helpless people'
      expect(christian_ministry.christian_ministry_filename).to eq(nil)

    end

  end

  describe 'event completion attributes' do
    it 'should return a hash of :attribute => value' do
      verifiables = FactoryGirl.create(:christian_ministry).verifiable_info
      expected_verifiables = {}
      expect(verifiables).to eq(expected_verifiables)
    end
  end
end
