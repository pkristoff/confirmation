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

  describe 'event completion attributes' do
    it 'should return a hash of :attribute => value' do
      verifiables = FactoryGirl.create(:pick_confirmation_name).verifiable_info
      expected_verifiables = {'Confirmation name': 'George'}
      expect(verifiables).to eq(expected_verifiables)
    end
  end
end
