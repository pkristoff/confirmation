# frozen_string_literal: true

require 'rails_helper'

describe RetreatVerification do
  describe 'basic creation' do
    it 'new can retrieve a RetreatVerification\'s info' do
      retreat_verification = RetreatVerification.new
      retreat_verification.where_held_retreat = 'xxx'
      expect(retreat_verification.where_held_retreat).to match 'xxx'
    end

    it 'FactoryBot can retrieve a RetreatVerification\'s info' do
      retreat_verification = FactoryBot.create(:retreat_verification)
      expect(retreat_verification.where_held_retreat).to match 'Here'
    end
  end

  describe 'event completion attributes' do
    it 'return a hash of :attribute => value' do
      verifiables = FactoryBot.create(:retreat_verification).verifiable_info
      expected_verifiables = {}
      expect(verifiables).to eq(expected_verifiables)
    end
  end
end
