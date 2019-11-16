# frozen_string_literal: true

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

    it 'FactoryBot can retrieve a ChristianMinistry\'s info' do
      candidate_sheet = FactoryBot.create(:candidate_sheet)
      expect(candidate_sheet.first_name).to match 'Sophia'
      expect(candidate_sheet.middle_name).to match 'Saraha'
      expect(candidate_sheet.last_name).to match 'Young'
      expect(candidate_sheet.address).not_to eq(nil)
    end
  end

  describe 'event completion attributes' do
    it 'should return a hash of :attribute => value' do
      candidate = FactoryBot.create(:candidate)
      verifiables = FactoryBot.create(:candidate_sheet).verifiable_info(candidate)
      expected_verifiables = { name: 'Sophia Saraha Young', grade: 10, street_1: '555 Xxx Ave.', street_2: '<nothing>', city: 'Clarksville', state: 'IN', zipcode: '47529' }
      expect(verifiables).to eq(expected_verifiables)
    end
  end

  describe 'email' do
    describe 'all email slots have values' do
      it 'should return them in order' do
        candidate_sheet = FactoryBot.create(:candidate_sheet)
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
        candidate_sheet = FactoryBot.create(:candidate_sheet)
        candidate_sheet.candidate_email = ''
        candidate_sheet.parent_email_1 = 'pe1@test.com'
        candidate_sheet.parent_email_2 = 'pe2@test.com'
        expect(candidate_sheet.to_email).to eq('pe1@test.com')
        expect(candidate_sheet.cc_email).to eq('pe2@test.com')
        expect(candidate_sheet.cc_email_2).to eq('')
      end
      it 'should move them up if parent 1 email is missing' do
        candidate_sheet = FactoryBot.create(:candidate_sheet)
        candidate_sheet.candidate_email = 'ce@test.com'
        candidate_sheet.parent_email_1 = ''
        candidate_sheet.parent_email_2 = 'pe2@test.com'
        expect(candidate_sheet.to_email).to eq('ce@test.com')
        expect(candidate_sheet.cc_email).to eq('pe2@test.com')
        expect(candidate_sheet.cc_email_2).to eq('')
      end
      it 'should move them up if parent 2 email is missing' do
        candidate_sheet = FactoryBot.create(:candidate_sheet)
        candidate_sheet.candidate_email = 'ce@test.com'
        candidate_sheet.parent_email_1 = 'pe1@test.com'
        candidate_sheet.parent_email_2 = ''
        expect(candidate_sheet.to_email).to eq('ce@test.com')
        expect(candidate_sheet.cc_email).to eq('pe1@test.com')
        expect(candidate_sheet.cc_email_2).to eq('')
      end
    end
    describe 'two email slot is missing' do
      it 'should move them up if candidate and parent_1 are missing' do
        candidate_sheet = FactoryBot.create(:candidate_sheet)
        candidate_sheet.candidate_email = ''
        candidate_sheet.parent_email_1 = ''
        candidate_sheet.parent_email_2 = 'pe2@test.com'
        expect(candidate_sheet.to_email).to eq('pe2@test.com')
        expect(candidate_sheet.cc_email).to eq('')
        expect(candidate_sheet.cc_email_2).to eq('')
      end
      it 'should move them up if parent_1 and parent_2 are missing' do
        candidate_sheet = FactoryBot.create(:candidate_sheet)
        candidate_sheet.candidate_email = 'ce@test.com'
        candidate_sheet.parent_email_1 = ''
        candidate_sheet.parent_email_2 = ''
        expect(candidate_sheet.to_email).to eq('ce@test.com')
        expect(candidate_sheet.cc_email).to eq('')
        expect(candidate_sheet.cc_email_2).to eq('')
      end
      it 'should move them up if candidate and parent_2 are missing' do
        candidate_sheet = FactoryBot.create(:candidate_sheet)
        candidate_sheet.candidate_email = ''
        candidate_sheet.parent_email_1 = 'pe1@test.com'
        candidate_sheet.parent_email_2 = ''
        expect(candidate_sheet.to_email).to eq('pe1@test.com')
        expect(candidate_sheet.cc_email).to eq('')
        expect(candidate_sheet.cc_email_2).to eq('')
      end
    end
    describe 'email validation' do
      it 'illegal emails' do
        candidate_sheet = CandidateSheet.new
        fill_in_cand(candidate_sheet)
        candidate_sheet.parent_email_1 = 'foo'
        candidate_sheet.validate_emails
        expect(candidate_sheet.errors.full_messages.size).to eq(1)
        expect(candidate_sheet.errors.full_messages[0]).to eq('Parent email 1 is an invalid email: foo')
      end
      it 'illegal emails' do
        candidate_sheet = CandidateSheet.new
        fill_in_cand(candidate_sheet)
        candidate_sheet.parent_email_2 = 'foo'
        candidate_sheet.validate_emails
        expect(candidate_sheet.errors.full_messages.size).to eq(2)
        expect(candidate_sheet.errors.full_messages[0]).to eq('Parent email 2 is an invalid email: foo')
      end
      it 'illegal emails' do
        candidate_sheet = CandidateSheet.new
        fill_in_cand(candidate_sheet)
        candidate_sheet.candidate_email = 'foo'
        candidate_sheet.validate_emails
        expect(candidate_sheet.errors.full_messages.size).to eq(1)
        expect(candidate_sheet.errors.full_messages[0]).to eq('Candidate email is an invalid email: foo')
      end
      it 'at least one email' do
        candidate_sheet = CandidateSheet.new
        fill_in_cand(candidate_sheet)
        candidate_sheet.validate_emails
        expect(candidate_sheet.errors.full_messages.size).to eq(1)
        expect(candidate_sheet.errors.full_messages[0]).to eq('Candidate email at least one email must be supplied.')
      end
      it 'no duplicate emails parent_email_2' do
        candidate_sheet = CandidateSheet.new
        fill_in_cand(candidate_sheet)
        candidate_sheet.candidate_email = 'foo@bar.com'
        candidate_sheet.parent_email_1 = 'baz@bar.com'
        candidate_sheet.parent_email_2 = 'baz@bar.com'
        candidate_sheet.validate_emails
        expect(candidate_sheet.errors.full_messages.size).to eq(1)
        expect(candidate_sheet.errors.full_messages[0]).to eq('Parent email 2 is a duplicate email, which is not allowed for a candidate - x x x.')
      end
      it 'no duplicate emails parent_email_2' do
        candidate_sheet = CandidateSheet.new
        fill_in_cand(candidate_sheet)
        candidate_sheet.candidate_email = 'baz@bar.com'
        candidate_sheet.parent_email_1 = 'baz@bar.com'
        candidate_sheet.parent_email_2 = 'foo@bar.com'
        candidate_sheet.validate_emails
        expect(candidate_sheet.errors.full_messages.size).to eq(1)
        expect(candidate_sheet.errors.full_messages[0]).to eq('Parent email 1 is a duplicate email, which is not allowed for a candidate - x x x.')
      end
      it 'no duplicate emails parent_email_2' do
        candidate_sheet = CandidateSheet.new
        fill_in_cand(candidate_sheet)
        candidate_sheet.candidate_email = 'baz@bar.com'
        candidate_sheet.parent_email_1 = 'foo@bar.com'
        candidate_sheet.parent_email_2 = 'baz@bar.com'
        candidate_sheet.validate_emails
        expect(candidate_sheet.errors.full_messages.size).to eq(1)
        expect(candidate_sheet.errors.full_messages[0]).to eq('Parent email 2 is a duplicate email, which is not allowed for a candidate - x x x.')
      end
      it 'no duplicate emails parent_email_2' do
        candidate_sheet = CandidateSheet.new
        fill_in_cand(candidate_sheet)
        candidate_sheet.candidate_email = 'baz@bar.com'
        candidate_sheet.parent_email_1 = 'baz@bar.com'
        candidate_sheet.parent_email_2 = 'baz@bar.com'
        candidate_sheet.validate_emails
        expect(candidate_sheet.errors.full_messages.size).to eq(3)
        expect(candidate_sheet.errors.full_messages[0]).to eq('Parent email 1 is a duplicate email, which is not allowed for a candidate - x x x.')
        expect(candidate_sheet.errors.full_messages[1]).to eq('Parent email 2 is a duplicate email, which is not allowed for a candidate - x x x.')
        expect(candidate_sheet.errors.full_messages[2]).to eq('Parent email 2 is a duplicate email, which is not allowed for a candidate - x x x.')
      end
    end
    def fill_in_cand(cand)
      cand.first_name = 'x'
      cand.middle_name = 'x'
      cand.last_name = 'x'
    end
  end
  describe 'validate_event_complete' do
    it 'should pass validation - new candidate_sheet validated' do
      candidate_sheet = FactoryBot.create(:candidate_sheet)

      msgs = candidate_sheet.errors.full_messages
      expect(candidate_sheet.validate_event_complete).to eq(true)
      expect(msgs.empty?).to eq(true), "msgs not empty=#{msgs}"
    end
    it 'should fail validation -  middle_name now required' do
      candidate_sheet = FactoryBot.create(:candidate_sheet)
      candidate_sheet.middle_name = nil

      expect(candidate_sheet.validate_event_complete).to eq(false)
      msgs = candidate_sheet.errors.full_messages
      expect(msgs[0]).to eq("Middle name can't be blank")
      expect(msgs.size).to eq(1), "msgs should be middle=#{msgs}"
    end
  end
end
