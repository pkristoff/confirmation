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
  end

  context 'with a CandidateEvent' do
    let!(:confirmation_event) { FactoryBot.create(:confirmation_event) }

    it 'create an admin with email and name' do
      candidate = AppFactory.create_candidate
      expect(candidate.candidate_events.size).to eq(1)
      expect(candidate.candidate_events[0].confirmation_event).to eq(confirmation_event)
    end
  end

  context 'with AppFactory.generate_default_status' do
    it 'Status.count == 4' do
      AppFactory.generate_default_status

      expect(Status.count).to eq(4)

      expect(Status.active.name).to eq(Status::ACTIVE)
      expect(Status.confirmed_elsewhere.name).to eq(Status::CONFIRMED_ELSEWHERE)
      expect(Status.deferred.name).to eq(Status::DEFERRED)
      expect(Status.from_another_parish.name).to eq(Status::FROM_ANOTHER_PARISH)
    end

    it 'Status.count > 0 raises a runtime error' do
      FactoryBot.create(:status)
      expect { AppFactory.generate_default_status }.to(raise_error { RuntimeError })
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
  before do
    # clean statuses out
    Status.find_each(&:destroy)
    AppFactory.generate_default_status
  end

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

    expect(Status.find_by(name: Status::ACTIVE)).not_to be_nil
    expect(Status.find_by(name: Status::DEFERRED)).not_to be_nil
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

  it 'create a confirmation_event, an admin, a candidate and a Visitor' do
    AppFactory.add_confirmation_event(BaptismalCertificate.event_key)

    AppFactory.generate_seed

    candidates = Candidate.all
    candidate = candidates[0]
    expect(candidate.candidate_events.size).to eq(1)
    expect(candidate.account_name).to eq('vickikristoff')
    expect(candidate.candidate_events.size).to eq(1)
    expect(candidate.candidate_events[0].event_key).to eq(BaptismalCertificate.event_key)

    expect(Visitor.count).to be(1)
    visitor = Visitor.first
    expect(visitor.home_parish).to eq('Change to home parish of confirmation')
    expect(visitor.home).to eq('HTML for home page')
    expect(visitor.about).to eq('HTML for about page')
    expect(visitor.contact).to eq('HTML for contact page')
    expect(visitor.home_parish_address.instance_of?(Address)).to be(true)
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
