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
      expect(candidate.address.street_1).to eq('')
      expect(candidate.candidate_events.size).to eq(0)
    end

    context 'with a CandidateEvent' do

      before(:each) { @confirmation_event = FactoryGirl.create :confirmation_event }

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
      AppFactory.add_confirmation_event(I18n.t('events.retreat_weekend'))
      AppFactory.add_confirmation_event(I18n.t('events.sign_agreement'))

      AppFactory.generate_seed

      expect(Admin.all.size).to eq(1)
      admin = Admin.all[0]
      expect(admin.name).to eq('Admin')

      candidate_events = Candidate.all
      expect(candidate_events.size).to eq(1)
      candidate = candidate_events[0]
      expect(candidate.account_name).to eq('vickikristoff')
      expect(candidate.candidate_events.size).to eq(3)
      expect(candidate.candidate_events[0].name).to eq(I18n.t('events.parent_meeting'))
      expect(candidate.candidate_events[1].name).to eq(I18n.t('events.retreat_weekend'))
      expect(candidate.candidate_events[2].name).to eq(I18n.t('events.sign_agreement'))

    end

    it 'should create 2 confirmation_event, an admin and a candidate then remove retreat_weekend event' do
      AppFactory.add_confirmation_event(I18n.t('events.parent_meeting'))
      AppFactory.add_confirmation_event(I18n.t('events.retreat_weekend'))

      AppFactory.generate_seed

      AppFactory.revert_confirmation_event(I18n.t('events.retreat_weekend'))

      candidate_events = Candidate.all
      expect(candidate_events.size).to eq(1)
      candidate = candidate_events[0]
      expect(candidate.account_name).to eq('vickikristoff')
      expect(candidate.candidate_events.size).to eq(1)
      expect(candidate.candidate_events[0].name).to eq(I18n.t('events.parent_meeting'))

    end

    it 'should create 2 confirmation_event, an admin and a candidate then remove parent_meeting event' do
      AppFactory.add_confirmation_event(I18n.t('events.parent_meeting'))
      AppFactory.add_confirmation_event(I18n.t('events.retreat_weekend'))

      AppFactory.generate_seed

      AppFactory.revert_confirmation_event(I18n.t('events.parent_meeting'))

      candidate_events = Candidate.all
      expect(candidate_events.size).to eq(1)
      candidate = candidate_events[0]
      expect(candidate.account_name).to eq('vickikristoff')
      expect(candidate.candidate_events.size).to eq(1)
      expect(candidate.candidate_events[0].name).to eq(I18n.t('events.retreat_weekend'))

    end

    it 'should add all confirmation events' do
      all_events_names = get_all_event_names
      AppFactory.add_confirmation_events
      all_events_names.each do |event_name|
        expect(ConfirmationEvent.find_by_name(I18n.t(event_name))).not_to eq(nil)
      end
      expect(ConfirmationEvent.all.size).to eq(all_events_names.size)
    end

  end


  def get_all_event_names
    config = YAML.load_file('config/locales/en.yml')
    all_events_names = []
    config['en']['events'].each do |event_name_entry|
      all_events_names << "events.#{event_name_entry[0]}"
    end
    all_events_names
  end
end