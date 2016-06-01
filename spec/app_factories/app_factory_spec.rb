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

  context 'generate_seed' do

    it 'shoul create a confirmation_event, an admin and a candidate' do
      AppFactory.generate_seed

      expect(ConfirmationEvent.all.size).to eq(1)
      confirmation_event = ConfirmationEvent.all[0]
      expect(confirmation_event.name).to eq('Parent Information Meeting')

      expect(Admin.all.size).to eq(1)
      admin = Admin.all[0]
      expect(admin.name).to eq('Admin')

      expect(Candidate.all.size).to eq(1)
      candidate = Candidate.all[0]
      expect(candidate.account_name).to eq('vickikristoff')
      expect(candidate.candidate_events.size).to eq(1)
      expect(candidate.candidate_events[0].name).to eq('Parent Information Meeting')

    end

  end
end