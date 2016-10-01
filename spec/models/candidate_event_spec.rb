require 'rails_helper'

xxx = 0
describe CandidateEvent, type: :model do
  describe 'relationship with ConfirmationEvent' do

    it 'basic creation' do

      confirmation_event = FactoryGirl.create(:confirmation_event)
      candidate_event = FactoryGirl.create(:candidate_event,
                                           completed_date: '2016-05-23',
                                           verified: true,
                                           confirmation_event: confirmation_event)

      expect(candidate_event.completed_date.to_s).to eq('2016-05-23')
      expect(candidate_event.verified).to eq(true)

      expect(candidate_event.name).to eq('Going out to eat')
      expect(candidate_event.confirmation_event.the_way_due_date.to_s).to eq('2016-05-31')
      expect(candidate_event.confirmation_event.chs_due_date.to_s).to eq('2016-05-24')
      expect(candidate_event.instructions).to eq("<h3>Do this</h3><ul>\n<li>one</li>\n<li>two</li>\n<li>three</li>\n</ul>")

      expect_confirmation_event(confirmation_event, 1, "<h3>Do this</h3><ul>\n<li>one</li>\n<li>two</li>\n<li>three</li>\n</ul>")

    end

    it 'two candidate_events same confirmation_event' do

      confirmation_event = FactoryGirl.create(:confirmation_event)
      candidate_event = FactoryGirl.create(:candidate_event,
                                           completed_date: '2016-05-23',
                                           verified: true,
                                           confirmation_event: confirmation_event)
      candidate_event_2 = FactoryGirl.create(:candidate_event,
                                             completed_date: '2016-05-22',
                                             verified: false,
                                             confirmation_event: confirmation_event)

      expect(candidate_event.completed_date.to_s).to eq('2016-05-23')
      expect(candidate_event.verified).to eq(true)

      expect(candidate_event.name).to eq('Going out to eat')
      expect(candidate_event.confirmation_event.chs_due_date.to_s).to eq('2016-05-24')
      expect(candidate_event.confirmation_event.the_way_due_date.to_s).to eq('2016-05-31')
      expect(candidate_event.instructions).to eq("<h3>Do this</h3><ul>\n<li>one</li>\n<li>two</li>\n<li>three</li>\n</ul>")

      expect(candidate_event_2.completed_date.to_s).to eq('2016-05-22')
      expect(candidate_event_2.verified).to eq(false)

      expect(candidate_event_2.name).to eq('Going out to eat')
      expect(candidate_event_2.confirmation_event.chs_due_date.to_s).to eq('2016-05-24')
      expect(candidate_event_2.confirmation_event.the_way_due_date.to_s).to eq('2016-05-31')
      expect(candidate_event.instructions).to eq("<h3>Do this</h3><ul>\n<li>one</li>\n<li>two</li>\n<li>three</li>\n</ul>")

      expect_confirmation_event(confirmation_event, 2, "<h3>Do this</h3><ul>\n<li>one</li>\n<li>two</li>\n<li>three</li>\n</ul>")
      expect(candidate_event.confirmation_event).to eq(candidate_event_2.confirmation_event)

    end
    it 'two candidate_events with different confirmation_events' do

      confirmation_event = FactoryGirl.create(:confirmation_event)
      confirmation_event_2 = FactoryGirl.create(:confirmation_event,
                                                name: 'Staying home',
                                                the_way_due_date: '2016-04-01',
                                                chs_due_date: '2016-04-02')
      candidate_event = FactoryGirl.create(:candidate_event,
                                           completed_date: '2016-05-23',
                                           verified: true,
                                           confirmation_event: confirmation_event)
      candidate_event_2 = FactoryGirl.create(:candidate_event,
                                             completed_date: '2016-05-22',
                                             verified: false,
                                             confirmation_event: confirmation_event_2)

      expect(candidate_event.completed_date.to_s).to eq('2016-05-23')
      expect(candidate_event.verified).to eq(true)

      expect(candidate_event.name).to eq('Going out to eat')
      expect(candidate_event.confirmation_event.the_way_due_date.to_s).to eq('2016-05-31')
      expect(candidate_event.confirmation_event.chs_due_date.to_s).to eq('2016-05-24')
      expect(candidate_event.instructions).to eq("<h3>Do this</h3><ul>\n<li>one</li>\n<li>two</li>\n<li>three</li>\n</ul>")

      expect(candidate_event_2.completed_date.to_s).to eq('2016-05-22')
      expect(candidate_event_2.verified).to eq(false)

      expect(candidate_event_2.confirmation_event.the_way_due_date.to_s).to eq('2016-04-01')
      expect(candidate_event_2.confirmation_event.chs_due_date.to_s).to eq('2016-04-02')
      expect(candidate_event_2.name).to eq('Staying home')

      expect_confirmation_event(confirmation_event, 1, "<h3>Do this</h3><ul>\n<li>one</li>\n<li>two</li>\n<li>three</li>\n</ul>")
      expect_confirmation_event(confirmation_event_2, 1, "<h3>Do this</h3><ul>\n<li>one</li>\n<li>two</li>\n<li>three</li>\n</ul>", '2016-04-01', '2016-04-02', 'Staying home')
      expect(candidate_event.confirmation_event).not_to eq(candidate_event_2.confirmation_event)

    end

    def expect_confirmation_event(confirmation_event, events_size, instructions, the_way_due_date='2016-05-31', chs_due_date='2016-05-24', name='Going out to eat')
      expect(confirmation_event.the_way_due_date.to_s).to eq(the_way_due_date)
      expect(confirmation_event.chs_due_date.to_s).to eq(chs_due_date)
      expect(confirmation_event.name).to eq(name)
      expect(confirmation_event.instructions).to eq(instructions)
      expect(confirmation_event.candidate_events.size).to eq(events_size)
    end
  end


  describe 'state model' do
    context 'confirmation event not started' do
      xxx += 1
      candidate = FactoryGirl.create(:candidate, account_name: "foo_#{xxx}") unless Candidate.find_by_account_name("foo_#{xxx}")
      candidate = Candidate.find_by_account_name("foo_#{xxx}") unless candidate
      confirmation_event_not_started = FactoryGirl.create(:confirmation_event, the_way_due_date: '', chs_due_date: '')
      candidate_event = candidate.add_candidate_event(confirmation_event_not_started)
      candidate_event.completed_date = ''
      candidate_event.verified = false

      it 'should not be started' do
        expect(candidate_event.started?).to eq(false)
      end
      it 'should not be awaiting_candidate?' do
        expect(candidate_event.awaiting_candidate?).to eq(false)
      end
      it 'should not be late?' do
        expect(candidate_event.late?).to eq(false)
      end
    end
    context 'confirmation event started' do
      xxx += 1
      candidate = FactoryGirl.create(:candidate, account_name: "baz_#{xxx}") unless Candidate.find_by_account_name("baz_#{xxx}")
      candidate = Candidate.find_by_account_name("baz_#{xxx}") unless candidate
      confirmation_event_started = FactoryGirl.create(:confirmation_event, the_way_due_date: '2016-04-01', chs_due_date: '2016-04-02')
      context 'candidate has done nothing' do
        candidate.candidate_events.clear
        candidate_event = candidate.add_candidate_event(confirmation_event_started)
        candidate_event.completed_date = ''
        candidate_event.verified = false

        it 'should be started' do
          expect(candidate_event.started?).to eq(true)
        end
        it 'should be awaiting_candidate?' do
          expect(candidate_event.awaiting_candidate?).to eq(true)
        end
        it 'should not be completed' do
          expect(candidate_event.completed?).to eq(false)
        end
        it 'should be late?' do
          expect(candidate_event.late?).to eq(true)
        end
        it 'should not be late? - due today' do
          confirmation_event_started.chs_due_date=Date.today
          confirmation_event_started.the_way_due_date=Date.today
          expect(candidate_event.late?).to eq(false)
        end
        it 'should not be late? - due in the future' do
          confirmation_event_started.chs_due_date=Date.today+1
          confirmation_event_started.the_way_due_date=Date.today+1
          expect(candidate_event.late?).to eq(false)
        end
      end
      context 'candidate has done the event awaiting admin approval' do
        xxx += 1
        candidate = FactoryGirl.create(:candidate, account_name: "bag_#{xxx}") unless Candidate.find_by_account_name("bag_#{xxx}")
        candidate = Candidate.find_by_account_name("bag_#{xxx}") unless candidate
        candidate.candidate_events.clear
        candidate_event = candidate.add_candidate_event(confirmation_event_started)
        candidate_event.completed_date = '2016-03-29'
        candidate_event.verified = false

        it 'should be started' do
          expect(candidate_event.started?).to eq(true)
        end
        it 'should not be awaiting candidate' do
          expect(candidate_event.awaiting_candidate?).to eq(false)
        end
        it 'should not be completed' do
          expect(candidate_event.completed?).to eq(false)
        end
        it 'should not be late?' do
          expect(candidate_event.late?).to eq(false)
        end
      end
      context 'candidate has done the event and admin has approved' do
        xxx += 1
        candidate = FactoryGirl.create(:candidate, account_name: "bag_#{xxx}") unless Candidate.find_by_account_name("bag_#{xxx}")
        candidate = Candidate.find_by_account_name("bag_#{xxx}") unless candidate
        candidate.candidate_events.clear
        candidate_event = candidate.add_candidate_event(confirmation_event_started)
        candidate_event.completed_date = '2016-03-29'
        candidate_event.verified = true
        it 'should be started' do
          expect(candidate_event.started?).to eq(true)
        end
        it 'should not be awaiting candidate' do
          expect(candidate_event.awaiting_candidate?).to eq(false)
        end
        it 'should not be completed' do
          expect(candidate_event.completed?).to eq(true)
        end
        it 'should not be late?' do
          expect(candidate_event.late?).to eq(false)
        end
      end
    end
  end

  describe 'route and candidate associations' do

    before(:each) do
      candidate = FactoryGirl.create(:candidate)
      AppFactory.add_confirmation_events
      @candidate = Candidate.find(candidate.id)
      @candidate.save
    end
    context 'routes' do
      it 'mapping candidate_event.name to route' do
        AppFactory.all_i18n_confirmation_event_names.each do |i18n_name|
          expect(@candidate.get_candidate_event(I18n.t(i18n_name)).route).to eq(i18n_name.split('.')[1].to_sym)
        end
      end
    end
  end
end
