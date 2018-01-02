require 'rails_helper'

describe PickConfirmationName, type: :model do

  describe 'basic creation' do

    it 'new can retrieve a PickConfirmationName\'s info' do
      pick_confirmation_name = PickConfirmationName.new
      pick_confirmation_name.saint_name = 'George'
      expect(pick_confirmation_name.saint_name).to match 'George'

    end

    it 'FactoryBot can retrieve a PickConfirmationName\'s info' do
      pick_confirmation_name = FactoryBot.create(:pick_confirmation_name)
      expect(pick_confirmation_name.saint_name).to match 'George'
    end

  end
end
