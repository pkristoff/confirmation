require 'rails_helper'

RSpec.describe CandidateEvent, type: :model do
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
      expect(candidate_event.due_date.to_s).to eq('2016-05-24')
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
      expect(candidate_event.due_date.to_s).to eq('2016-05-24')
      expect(candidate_event.instructions).to eq("<h3>Do this</h3><ul>\n<li>one</li>\n<li>two</li>\n<li>three</li>\n</ul>")

      expect(candidate_event_2.completed_date.to_s).to eq('2016-05-22')
      expect(candidate_event_2.verified).to eq(false)

      expect(candidate_event_2.name).to eq('Going out to eat')
      expect(candidate_event_2.due_date.to_s).to eq('2016-05-24')
      expect(candidate_event.instructions).to eq("<h3>Do this</h3><ul>\n<li>one</li>\n<li>two</li>\n<li>three</li>\n</ul>")

      expect_confirmation_event(confirmation_event, 2, "<h3>Do this</h3><ul>\n<li>one</li>\n<li>two</li>\n<li>three</li>\n</ul>")
      expect(candidate_event.confirmation_event).to eq(candidate_event_2.confirmation_event)

    end
    it 'two candidate_events with different confirmation_events' do

      confirmation_event = FactoryGirl.create(:confirmation_event)
      confirmation_event_2 = FactoryGirl.create(:confirmation_event,
                                                name: 'Staying home',
                                                due_date: '2016-04-01')
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
      expect(candidate_event.due_date.to_s).to eq('2016-05-24')
      expect(candidate_event.instructions).to eq("<h3>Do this</h3><ul>\n<li>one</li>\n<li>two</li>\n<li>three</li>\n</ul>")

      expect(candidate_event_2.completed_date.to_s).to eq('2016-05-22')
      expect(candidate_event_2.verified).to eq(false)

      expect(candidate_event_2.due_date.to_s).to eq('2016-04-01')
      expect(candidate_event_2.name).to eq('Staying home')

      expect_confirmation_event(confirmation_event, 1, "<h3>Do this</h3><ul>\n<li>one</li>\n<li>two</li>\n<li>three</li>\n</ul>")
      expect_confirmation_event(confirmation_event_2, 1, "<h3>Do this</h3><ul>\n<li>one</li>\n<li>two</li>\n<li>three</li>\n</ul>", '2016-04-01', 'Staying home')
      expect(candidate_event.confirmation_event).not_to eq(candidate_event_2.confirmation_event)

    end

    def expect_confirmation_event(confirmation_event, events_size, instructions, due_date='2016-05-24', name='Going out to eat')
      expect(confirmation_event.due_date.to_s).to eq(due_date)
      expect(confirmation_event.name).to eq(name)
      expect(confirmation_event.instructions).to eq(instructions)
      expect(confirmation_event.candidate_events.size).to eq(events_size)
    end
  end


  describe 'state model' do
    context 'confirmation event not started' do
      let! (:confirmation_event_not_started) { FactoryGirl.create(:confirmation_event, due_date: '') }
      let! (:candidate_event) { FactoryGirl.create(:candidate_event,
                                                   completed_date: '',
                                                   verified: false,
                                                   confirmation_event: confirmation_event_not_started) }
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
      let! (:confirmation_event_started) { FactoryGirl.create(:confirmation_event, due_date: '2016-04-01') }
      context 'candidate has done nothing' do
        let! (:candidate_event) { FactoryGirl.create(:candidate_event,
                                                     completed_date: '',
                                                     verified: false,
                                                     confirmation_event: confirmation_event_started) }

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
          confirmation_event_started.due_date=Date.today
          expect(candidate_event.late?).to eq(false)
        end
        it 'should not be late? - due in the future' do
          confirmation_event_started.due_date=Date.today+1
          expect(candidate_event.late?).to eq(false)
        end
      end
      context 'candidate has done the event awaiting admin approval' do
        let! (:candidate_event) { FactoryGirl.create(:candidate_event,
                                                     completed_date: '2016-03-29',
                                                     verified: false,
                                                     confirmation_event: confirmation_event_started) }
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
        let! (:candidate_event) { FactoryGirl.create(:candidate_event,
                                                     completed_date: '2016-03-29',
                                                     verified: true,
                                                     confirmation_event: confirmation_event_started) }
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
end
