# frozen_string_literal: true

require 'yaml'

describe AppFactory do
  context 'when creating an admin' do
    it 'create an empty admin' do
      admin = AppFactory.create_admin
      expect(admin.email).to eq('')
      expect(admin.name).to eq('')
    end

    it 'create an admin with email and name' do
      admin = AppFactory.create_admin(email: 'foo@bar.com', name: 'george')
      expect(admin.email).to eq('foo@bar.com')
      expect(admin.name).to eq('george')
    end
  end

  context 'when creating a candidate' do
    it 'create an empty candidate' do
      candidate = AppFactory.create_candidate
      expect(candidate.account_name).to eq('')
      expect(candidate.candidate_events.size).to eq(0)
    end

    context 'with a CandidateEvent' do
      let!(:confirmation_event) { FactoryBot.create(:confirmation_event) }

      it 'create an admin with email and name' do
        candidate = AppFactory.create_candidate
        expect(candidate.candidate_events.size).to eq(1)
        expect(candidate.candidate_events[0].confirmation_event).to eq(confirmation_event)
      end
    end
  end

  context 'with create' do
    it 'create an Admin' do
      admin = AppFactory.create(Admin)
      expect(admin.class).to eq(Admin)
    end

    it 'create a Candidate' do
      candidate = AppFactory.create(Candidate)
      expect(candidate.class).to eq(Candidate)
    end
  end

  context 'with confirmation events' do
    it 'create a confirmation_event, an admin and a candidate' do
      AppFactory.add_confirmation_event(Candidate.parent_meeting_event_key)
      AppFactory.add_confirmation_event(RetreatVerification.event_key)
      AppFactory.add_confirmation_event(Candidate.covenant_agreement_event_key)

      AppFactory.generate_seed

      expect(Admin.all.size).to eq(1)
      admin = Admin.all[0]
      expect(admin.name).to eq('Admin')

      candidate_events = Candidate.all
      expect(candidate_events.size).to eq(1)
      candidate = candidate_events[0]
      expect(candidate.account_name).to eq('vickikristoff')
      expect(candidate.candidate_events.size).to eq(3)
      expect(candidate.candidate_events_sorted[0].event_key).to eq(RetreatVerification.event_key)
      expect(candidate.candidate_events_sorted[1].event_key).to eq(Candidate.covenant_agreement_event_key)
      expect(candidate.candidate_events_sorted[2].event_key).to eq(Candidate.parent_meeting_event_key)
    end

    it 'create 2 confirmation_event, an admin and a candidate then remove retreat_weekend event' do
      AppFactory.add_confirmation_event(Candidate.parent_meeting_event_key)
      AppFactory.add_confirmation_event(RetreatVerification.event_key)

      AppFactory.generate_seed

      AppFactory.revert_confirmation_event(RetreatVerification.event_key)

      candidate_events = Candidate.all
      expect(candidate_events.size).to eq(1)
      candidate = candidate_events[0]
      expect(candidate.account_name).to eq('vickikristoff')
      expect(candidate.candidate_events.size).to eq(1)
      expect(candidate.candidate_events[0].event_key).to eq(Candidate.parent_meeting_event_key)
    end

    it 'create 2 confirmation_event, an admin and a candidate then remove parent_meeting event' do
      AppFactory.add_confirmation_event(Candidate.parent_meeting_event_key)
      AppFactory.add_confirmation_event(RetreatVerification.event_key)

      AppFactory.generate_seed

      AppFactory.revert_confirmation_event(Candidate.parent_meeting_event_key)

      candidate_events = Candidate.all
      expect(candidate_events.size).to eq(1)
      candidate = candidate_events[0]
      expect(candidate.account_name).to eq('vickikristoff')
      expect(candidate.candidate_events.size).to eq(1)
      expect(candidate.candidate_events[0].event_key).to eq(RetreatVerification.event_key)
    end

    it 'add all confirmation events' do
      every_event_names = AppFactory.all_i18n_confirmation_event_keys
      AppFactory.add_confirmation_events
      every_event_names.each do |event_key|
        expect(ConfirmationEvent.find_by(event_key: event_key)).not_to be_nil, "Unknown event_key=#{event_key}"
      end
      expect(ConfirmationEvent.all.size).to eq(every_event_names.size)
    end
  end
end
