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

    end

  end
end
