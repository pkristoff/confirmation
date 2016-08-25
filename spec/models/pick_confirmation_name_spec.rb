require 'rails_helper'

describe PickConfirmationName, type: :model do

  describe 'basic creation' do

    it 'new can retrieve a PickConfirmationName\'s info' do
      pick_confirmation_name = PickConfirmationName.new
      pick_confirmation_name.saint_name = 'George'
      expect(pick_confirmation_name.saint_name).to match 'George'

    end

    it 'FactoryGirl can retrieve a PickConfirmationName\'s info' do
      pick_confirmation_name = FactoryGirl.create(:pick_confirmation_name)
      expect(pick_confirmation_name.saint_name).to match 'George'
      expect(pick_confirmation_name.pick_confirmation_name_filename).to eq(nil)

    end

  end
end
