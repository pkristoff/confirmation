# frozen_string_literal: true

require 'rails_helper'

describe ChristianMinistry do
  describe 'basic creation' do
    it 'new can retrieve a ChristianMinistry\'s info' do
      christian_ministry = ChristianMinistry.new
      christian_ministry.what_service = 'xxx'
      expect(christian_ministry.what_service).to match 'xxx'
    end

    it 'FactoryBot can retrieve a ChristianMinistry\'s info' do
      christian_ministry = FactoryBot.create(:christian_ministry)
      expect(christian_ministry.what_service).to match 'Helped some helpless people'
    end
  end
end
