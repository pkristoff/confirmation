require 'rails_helper'

describe ChristianMinistry, type: :model do

  describe 'basic creation' do

    it 'new can retrieve a ChristianMinistry\'s info' do
      pick_confirmation_name = ChristianMinistry.new
      pick_confirmation_name.what_service = 'xxx'
      expect(pick_confirmation_name.what_service).to match 'xxx'

    end

    it 'FactoryGirl can retrieve a ChristianMinistry\'s info' do
      pick_confirmation_name = FactoryGirl.create(:christian_ministry)
      expect(pick_confirmation_name.what_service).to match 'Helped some helpless people'
      expect(pick_confirmation_name.christian_ministry_filename).to eq(nil)

    end

  end
end
