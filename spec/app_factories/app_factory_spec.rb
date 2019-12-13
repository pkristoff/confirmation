# frozen_string_literal: true

require 'yaml'

describe AppFactory do
  context 'creating an admin' do
    it 'should create an empty admin' do
      admin = AppFactory.create_admin
      expect(admin.email).to eq('')
      expect(admin.name).to eq('')
    end

    it 'should create an admin with email and name' do
      admin = AppFactory.create_admin(email: 'foo@bar.com', name: 'george')
      expect(admin.email).to eq('foo@bar.com')
      expect(admin.name).to eq('george')
    end
  end

  context 'creating a candidate' do
    it 'should create an empty candidate' do
      candidate = AppFactory.create_candidate
      expect(candidate.account_name).to eq('')
      expect(candidate.candidate_sheet.address.street_1).to eq('')
      expect(candidate.candidate_events.size).to eq(0)
    end

    context 'with a CandidateEvent' do
      before(:each) { @confirmation_event = FactoryBot.create :confirmation_event }

      it 'should create an admin with email and name' do
        candidate = AppFactory.create_candidate
        expect(candidate.candidate_events.size).to eq(1)
        expect(candidate.candidate_events[0].confirmation_event).to eq(@confirmation_event)
      end
    end
  end

  context 'create' do
    it 'should create an Admin' do
      admin = AppFactory.create(Admin)
      expect(admin.class).to eq(Admin)
    end

    it 'should create a Candidate' do
      candidate = AppFactory.create(Candidate)
      expect(candidate.class).to eq(Candidate)
    end
  end

  context 'confirmation events' do
    it 'should create a confirmation_event, an admin and a candidate' do
      AppFactory.add_confirmation_event(I18n.t('events.parent_meeting'))
      AppFactory.add_confirmation_event(I18n.t('events.retreat_verification'))
      AppFactory.add_confirmation_event(I18n.t('events.candidate_covenant_agreement'))
      # AppFactory.add_confirmation_event(I18n.t('events.sponsor_agreement'))

      AppFactory.generate_seed

      expect(Admin.all.size).to eq(1)
      admin = Admin.all[0]
      expect(admin.name).to eq('Admin')

      candidate_events = Candidate.all
      expect(candidate_events.size).to eq(1)
      candidate = candidate_events[0]
      expect(candidate.account_name).to eq('vickikristoff')
      expect(candidate.candidate_events.size).to eq(3)
      expect(candidate.candidate_events_sorted[0].name).to eq(I18n.t('events.retreat_verification'))
      expect(candidate.candidate_events_sorted[1].name).to eq(I18n.t('events.candidate_covenant_agreement'))
      expect(candidate.candidate_events_sorted[2].name).to eq(I18n.t('events.parent_meeting'))
    end

    it 'should create 2 confirmation_event, an admin and a candidate then remove retreat_weekend event' do
      AppFactory.add_confirmation_event(I18n.t('events.parent_meeting'))
      AppFactory.add_confirmation_event(I18n.t('events.retreat_verification'))

      AppFactory.generate_seed

      AppFactory.revert_confirmation_event(I18n.t('events.retreat_verification'))

      candidate_events = Candidate.all
      expect(candidate_events.size).to eq(1)
      candidate = candidate_events[0]
      expect(candidate.account_name).to eq('vickikristoff')
      expect(candidate.candidate_events.size).to eq(1)
      expect(candidate.candidate_events[0].name).to eq(I18n.t('events.parent_meeting'))
    end

    it 'should create 2 confirmation_event, an admin and a candidate then remove parent_meeting event' do
      AppFactory.add_confirmation_event(I18n.t('events.parent_meeting'))
      AppFactory.add_confirmation_event(I18n.t('events.retreat_verification'))

      AppFactory.generate_seed

      AppFactory.revert_confirmation_event(I18n.t('events.parent_meeting'))

      candidate_events = Candidate.all
      expect(candidate_events.size).to eq(1)
      candidate = candidate_events[0]
      expect(candidate.account_name).to eq('vickikristoff')
      expect(candidate.candidate_events.size).to eq(1)
      expect(candidate.candidate_events[0].name).to eq(I18n.t('events.retreat_verification'))
    end

    it 'should add all confirmation events' do
      every_event_names = all_event_keys
      AppFactory.add_confirmation_events
      every_event_names.each do |event_key|
        expect(ConfirmationEvent.find_by(name: event_key)).not_to eq(nil)
      end
      expect(ConfirmationEvent.all.size).to eq(all_event_keys.size)
    end
  end

  def all_event_keys
    config = YAML.load_file('config/locales/en.yml')
    every_event_keys = []
    config['en']['events'].each do |event_name_entry|
      every_event_keys << event_name_entry[1]
    end
    every_event_keys
  end
end
