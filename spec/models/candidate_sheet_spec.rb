require 'rails_helper'

describe CandidateSheet, type: :model do

  describe 'basic creation' do

    it 'new can retrieve a CandidateSheet\'s info' do
      candidate_sheet = CandidateSheet.new
      candidate_sheet.first_name = 'xxx'
      expect(candidate_sheet.first_name).to match 'xxx'

    end

    it 'new can retrieve a CandidateSheet\'s middle_name' do
      candidate_sheet = CandidateSheet.new
      candidate_sheet.middle_name = 'xxx'
      expect(candidate_sheet.middle_name).to match 'xxx'

    end

    it 'FactoryGirl can retrieve a ChristianMinistry\'s info' do
      candidate_sheet = FactoryGirl.create(:candidate_sheet)
      expect(candidate_sheet.first_name).to match 'Sophia'
      expect(candidate_sheet.middle_name).to match 'Saraha'
      expect(candidate_sheet.last_name).to match 'Young'
      expect(candidate_sheet.address).not_to eq(nil)

    end

  end

  describe 'event completion attributes' do
    it 'should return a hash of :attribute => value' do
      candidate = FactoryGirl.create(:candidate)
      verifiables = FactoryGirl.create(:candidate_sheet).verifiable_info(candidate)
      expected_verifiables = {name: 'Sophia Young', grade: 10, street_1: '555 Xxx Ave.', street_2: '<nothing>', city: 'Clarksville', state: 'IN', zipcode: '47529'}
      expect(verifiables).to eq(expected_verifiables)
    end
  end

  describe 'email' do
    describe 'all email slots have values' do
      it 'should return them in order' do
        candidate_sheet = FactoryGirl.create(:candidate_sheet)
        candidate_sheet.candidate_email = 'ce@test.com'
        candidate_sheet.parent_email_1 = 'pe1@test.com'
        candidate_sheet.parent_email_2 = 'pe2@test.com'
        expect(candidate_sheet.to_email).to eq('ce@test.com')
        expect(candidate_sheet.cc_email).to eq('pe1@test.com')
        expect(candidate_sheet.cc_email_2).to eq('pe2@test.com')
      end
    end
    describe 'one email slot is missing' do
      it 'should move them up if candidate is missing' do
        candidate_sheet = FactoryGirl.create(:candidate_sheet)
        candidate_sheet.candidate_email = nil
        candidate_sheet.parent_email_1 = 'pe1@test.com'
        candidate_sheet.parent_email_2 = 'pe2@test.com'
        expect(candidate_sheet.to_email).to eq('pe1@test.com')
        expect(candidate_sheet.cc_email).to eq('pe2@test.com')
        expect(candidate_sheet.cc_email_2).to eq(nil)
      end
      it 'should move them up if parent 1 email is missing' do
        candidate_sheet = FactoryGirl.create(:candidate_sheet)
        candidate_sheet.candidate_email = 'ce@test.com'
        candidate_sheet.parent_email_1 = nil
        candidate_sheet.parent_email_2 = 'pe2@test.com'
        expect(candidate_sheet.to_email).to eq('ce@test.com')
        expect(candidate_sheet.cc_email).to eq('pe2@test.com')
        expect(candidate_sheet.cc_email_2).to eq(nil)
      end
      it 'should move them up if parent 2 email is missing' do
        candidate_sheet = FactoryGirl.create(:candidate_sheet)
        candidate_sheet.candidate_email = 'ce@test.com'
        candidate_sheet.parent_email_1 = 'pe1@test.com'
        candidate_sheet.parent_email_2 = nil
        expect(candidate_sheet.to_email).to eq('ce@test.com')
        expect(candidate_sheet.cc_email).to eq('pe1@test.com')
        expect(candidate_sheet.cc_email_2).to eq(nil)
      end
    end
    describe 'two email slot is missing' do
      it 'should move them up if candidate and parent_1 are missing' do
        candidate_sheet = FactoryGirl.create(:candidate_sheet)
        candidate_sheet.candidate_email = nil
        candidate_sheet.parent_email_1 = nil
        candidate_sheet.parent_email_2 = 'pe2@test.com'
        expect(candidate_sheet.to_email).to eq('pe2@test.com')
        expect(candidate_sheet.cc_email).to eq(nil)
        expect(candidate_sheet.cc_email_2).to eq(nil)
      end
      it 'should move them up if parent_1 and parent_2 are missing' do
        candidate_sheet = FactoryGirl.create(:candidate_sheet)
        candidate_sheet.candidate_email = 'ce@test.com'
        candidate_sheet.parent_email_1 = nil
        candidate_sheet.parent_email_2 = nil
        expect(candidate_sheet.to_email).to eq('ce@test.com')
        expect(candidate_sheet.cc_email).to eq(nil)
        expect(candidate_sheet.cc_email_2).to eq(nil)
      end
      it 'should move them up if candidate and parent_2 are missing' do
        candidate_sheet = FactoryGirl.create(:candidate_sheet)
        candidate_sheet.candidate_email = nil
        candidate_sheet.parent_email_1 = 'pe1@test.com'
        candidate_sheet.parent_email_2 = nil
        expect(candidate_sheet.to_email).to eq('pe1@test.com')
        expect(candidate_sheet.cc_email).to eq(nil)
        expect(candidate_sheet.cc_email_2).to eq(nil)
      end
    end
  end
end