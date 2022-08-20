# frozen_string_literal: true

require 'rails_helper'

xxx = 0
describe CandidateEvent, type: :model do
  before do
    @today = Time.zone.today
  end

  describe 'relationship with ConfirmationEvent' do
    it 'basic creation' do
      confirmation_event = FactoryBot.create(:confirmation_event)
      candidate_event = FactoryBot.create(:candidate_event,
                                          completed_date: '2016-05-23',
                                          verified: true,
                                          confirmation_event: confirmation_event)

      expect(candidate_event.completed_date.to_s).to eq('2016-05-23')
      expect(candidate_event.verified).to be(true)

      expect(candidate_event.event_key).to eq('Going out to eat')
      expect(candidate_event.confirmation_event.the_way_due_date.to_s).to eq('2016-05-31')
      expect(candidate_event.confirmation_event.chs_due_date.to_s).to eq('2016-05-24')
      expect(candidate_event.instructions).to eq("<h3>Do this</h3><ul>\n<li>one</li>\n<li>two</li>\n<li>three</li>\n</ul>")

      expect_confirmation_event(confirmation_event, 1, "<h3>Do this</h3><ul>\n<li>one</li>\n<li>two</li>\n<li>three</li>\n</ul>")
    end

    it 'two candidate_events same confirmation_event' do
      confirmation_event = FactoryBot.create(:confirmation_event)
      candidate_event = FactoryBot.create(:candidate_event,
                                          completed_date: '2016-05-23',
                                          verified: true,
                                          confirmation_event: confirmation_event)
      candidate_event2 = FactoryBot.create(:candidate_event,
                                           completed_date: '2016-05-22',
                                           verified: false,
                                           confirmation_event: confirmation_event)

      expect(candidate_event.completed_date.to_s).to eq('2016-05-23')
      expect(candidate_event.verified).to be(true)

      expect(candidate_event.event_key).to eq('Going out to eat')
      expect(candidate_event.confirmation_event.chs_due_date.to_s).to eq('2016-05-24')
      expect(candidate_event.confirmation_event.the_way_due_date.to_s).to eq('2016-05-31')
      expect(candidate_event.instructions).to eq("<h3>Do this</h3><ul>\n<li>one</li>\n<li>two</li>\n<li>three</li>\n</ul>")

      expect(candidate_event2.completed_date.to_s).to eq('2016-05-22')
      expect(candidate_event2.verified).to be(false)

      expect(candidate_event2.event_key).to eq('Going out to eat')
      expect(candidate_event2.confirmation_event.chs_due_date.to_s).to eq('2016-05-24')
      expect(candidate_event2.confirmation_event.the_way_due_date.to_s).to eq('2016-05-31')
      expect(candidate_event.instructions).to eq("<h3>Do this</h3><ul>\n<li>one</li>\n<li>two</li>\n<li>three</li>\n</ul>")

      expect_confirmation_event(confirmation_event, 2, "<h3>Do this</h3><ul>\n<li>one</li>\n<li>two</li>\n<li>three</li>\n</ul>")
      expect(candidate_event.confirmation_event).to eq(candidate_event2.confirmation_event)
    end

    it 'two candidate_events with different confirmation_events' do
      confirmation_event = FactoryBot.create(:confirmation_event)
      confirmation_event2 = FactoryBot.create(:confirmation_event,
                                              event_key: 'Staying home',
                                              the_way_due_date: '2016-04-01',
                                              chs_due_date: '2016-04-02')
      candidate_event = FactoryBot.create(:candidate_event,
                                          completed_date: '2016-05-23',
                                          verified: true,
                                          confirmation_event: confirmation_event)
      candidate_event2 = FactoryBot.create(:candidate_event,
                                           completed_date: '2016-05-22',
                                           verified: false,
                                           confirmation_event: confirmation_event2)

      expect(candidate_event.completed_date.to_s).to eq('2016-05-23')
      expect(candidate_event.verified).to be(true)

      expect(candidate_event.event_key).to eq('Going out to eat')
      expect(candidate_event.confirmation_event.the_way_due_date.to_s).to eq('2016-05-31')
      expect(candidate_event.confirmation_event.chs_due_date.to_s).to eq('2016-05-24')
      expect(candidate_event.instructions).to eq("<h3>Do this</h3><ul>\n<li>one</li>\n<li>two</li>\n<li>three</li>\n</ul>")

      expect(candidate_event2.completed_date.to_s).to eq('2016-05-22')
      expect(candidate_event2.verified).to be(false)

      expect(candidate_event2.confirmation_event.the_way_due_date.to_s).to eq('2016-04-01')
      expect(candidate_event2.confirmation_event.chs_due_date.to_s).to eq('2016-04-02')
      expect(candidate_event2.event_key).to eq('Staying home')

      expect_confirmation_event(confirmation_event, 1, "<h3>Do this</h3><ul>\n<li>one</li>\n<li>two</li>\n<li>three</li>\n</ul>")
      expect_confirmation_event(confirmation_event2,
                                1,
                                "<h3>Do this</h3><ul>\n<li>one</li>\n<li>two</li>\n<li>three</li>\n</ul>",
                                '2016-04-01',
                                '2016-04-02',
                                'Staying home')
      expect(candidate_event.confirmation_event).not_to eq(candidate_event2.confirmation_event)
    end

    private

    def expect_confirmation_event(confirmation_event,
                                  events_size,
                                  instructions,
                                  the_way_due_date = '2016-05-31',
                                  chs_due_date = '2016-05-24',
                                  event_key = 'Going out to eat')
      expect(confirmation_event.the_way_due_date.to_s).to eq(the_way_due_date)
      expect(confirmation_event.chs_due_date.to_s).to eq(chs_due_date)
      expect(confirmation_event.event_key).to eq(event_key)
      expect(confirmation_event.instructions).to eq(instructions)
      expect(confirmation_event.candidate_events.size).to eq(events_size)
    end
  end

  describe 'state model' do
    context 'when confirmation event not started' do
      xxx += 1
      candidate = nil
      candidate = FactoryBot.create(:candidate, account_name: "foo_#{xxx}") unless Candidate.find_by(account_name: "foo_#{xxx}")
      candidate ||= Candidate.find_by(account_name: "foo_#{xxx}")
      confirmation_event_not_started = FactoryBot.create(:confirmation_event, the_way_due_date: '', chs_due_date: '')
      candidate_event = candidate.add_candidate_event(confirmation_event_not_started)
      candidate_event.completed_date = ''
      candidate_event.verified = false

      it 'not be started' do
        expect(candidate_event.started?).to be(false)
      end

      it 'not be awaiting_candidate?' do
        expect(candidate_event.awaiting_candidate?).to be(false)
      end

      it 'not be late?' do
        expect(candidate_event.late?).to be(false)
      end
    end

    context 'when confirmation event started' do
      xxx += 1
      candidate = FactoryBot.create(:candidate, account_name: "baz_#{xxx}") unless Candidate.find_by(account_name: "baz_#{xxx}")
      candidate ||= Candidate.find_by(account_name: "baz_#{xxx}")
      confirmation_event_started = FactoryBot.create(:confirmation_event,
                                                     the_way_due_date: '2016-04-01',
                                                     chs_due_date: '2016-04-02')

      context 'when candidate has done nothing' do
        candidate.candidate_events.clear
        candidate_event = candidate.add_candidate_event(confirmation_event_started)
        candidate_event.completed_date = ''
        candidate_event.verified = false

        it 'be started' do
          expect(candidate_event.started?).to be(true)
        end

        it 'be awaiting_candidate?' do
          expect(candidate_event.awaiting_candidate?).to be(true)
        end

        it 'not be completed' do
          expect(candidate_event.completed?).to be(false)
        end

        it 'be late?' do
          expect(candidate_event.late?).to be(true)
        end

        it 'not be late? - due today' do
          confirmation_event_started.chs_due_date = @today
          confirmation_event_started.the_way_due_date = @today
          expect(candidate_event.late?).to be(false)
        end

        it 'not be late? - due in the future' do
          confirmation_event_started.chs_due_date = @today + 1
          confirmation_event_started.the_way_due_date = @today + 1
          expect(candidate_event.late?).to be(false)
        end
      end

      context 'when candidate has done the event awaiting admin approval' do
        xxx += 1
        candidate = nil
        candidate = FactoryBot.create(:candidate, account_name: "bag_#{xxx}") unless Candidate.find_by(account_name: "bag_#{xxx}")
        candidate ||= Candidate.find_by(account_name: "bag_#{xxx}")
        candidate.candidate_events.clear
        candidate_event = candidate.add_candidate_event(confirmation_event_started)
        candidate_event.completed_date = '2016-03-29'
        candidate_event.verified = false

        it 'be started' do
          expect(candidate_event.started?).to be(true)
        end

        it 'not be awaiting candidate' do
          expect(candidate_event.awaiting_candidate?).to be(false)
        end

        it 'not be completed' do
          expect(candidate_event.completed?).to be(false)
        end

        it 'not be late?' do
          expect(candidate_event.late?).to be(false)
        end
      end

      context 'when candidate has done the event and admin has approved' do
        xxx += 1
        candidate = nil
        candidate = FactoryBot.create(:candidate, account_name: "bag_#{xxx}") unless Candidate.find_by(account_name: "bag_#{xxx}")
        candidate ||= Candidate.find_by(account_name: "bag_#{xxx}")
        candidate.candidate_events.clear
        candidate_event = candidate.add_candidate_event(confirmation_event_started)
        candidate_event.completed_date = '2016-03-29'
        candidate_event.verified = true
        it 'be started' do
          expect(candidate_event.started?).to be(true)
        end

        it 'not be awaiting candidate' do
          expect(candidate_event.awaiting_candidate?).to be(false)
        end

        it 'not be completed' do
          expect(candidate_event.completed?).to be(true)
        end

        it 'not be late?' do
          expect(candidate_event.late?).to be(false)
        end
      end
    end
  end

  describe 'status' do
    before do
      candidate = FactoryBot.create(:candidate)
      event_key = Candidate.covenant_agreement_event_key
      AppFactory.add_confirmation_event(event_key)
      @candidate = Candidate.find_by(account_name: candidate.account_name)
      @candidate_event = @candidate.get_candidate_event(event_key)
    end

    it 'if nothing started then return "Not Started"' do
      @candidate_event.confirmation_event.chs_due_date = nil
      @candidate_event.confirmation_event.the_way_due_date = nil
      expect(@candidate_event.status).to eq('Not Started')
    end

    it 'if confirmation event due date set for today and < 30 days in future but candidate has done nothing "Coming Due"' do
      @candidate_event.confirmation_event.chs_due_date = @today
      @candidate_event.confirmation_event.the_way_due_date = @today
      expect(@candidate_event.status).to eq('Coming Due')
    end

    it 'if confirmation event due date set < 30 days in the future but candidate has done nothing "Coming Due"' do
      @candidate_event.confirmation_event.chs_due_date = @today + 29
      @candidate_event.confirmation_event.the_way_due_date = @today + 29
      expect(@candidate_event.status).to eq('Coming Due')
    end

    it 'if confirmation event due date set >= to 30 days in future but candidate has done nothing "Awaiting Candidate"' do
      @candidate_event.confirmation_event.chs_due_date = @today + 30
      @candidate_event.confirmation_event.the_way_due_date = @today + 30
      expect(@candidate_event.status).to eq('Awaiting Candidate')
    end

    it 'if confirmation event due date set before today but candidate has done nothing "Late"' do
      @candidate_event.confirmation_event.chs_due_date = @today - 1
      @candidate_event.confirmation_event.the_way_due_date = @today - 1
      expect(@candidate_event.status).to eq('Late')
    end

    it 'if confirmation event due date set, candidate completes event and admin has not verified "Awaiting Admin"' do
      @candidate_event.confirmation_event.chs_due_date = @today
      @candidate_event.confirmation_event.the_way_due_date = @today
      @candidate_event.completed_date = @today
      @candidate_event.verified = false
      expect(@candidate_event.status).to eq('Awaiting Admin')
    end

    it 'if confirmation event due date set, candidate completes event and admin verified "Completed"' do
      @candidate_event.confirmation_event.chs_due_date = @today
      @candidate_event.confirmation_event.the_way_due_date = @today
      @candidate_event.completed_date = @today
      @candidate_event.verified = true
      expect(@candidate_event.status).to eq('Verified')
    end
  end

  describe 'mark_completed' do
    it 'validated event will be completed and verified.' do
      candidate = FactoryBot.create(:candidate)
      event_key = BaptismalCertificate.event_key
      AppFactory.add_confirmation_event(event_key)
      candidate = Candidate.find_by(account_name: candidate.account_name)
      candidate_event = candidate.get_candidate_event(event_key)

      [[BaptismalCertificate, false], [CandidateSheet, true], [ChristianMinistry, true],
       [PickConfirmationName, false], [RetreatVerification, false], [SponsorCovenant, true],
       [SponsorEligibility, false]].each do |association_class_pair|
        candidate_event.completed_date = nil
        candidate_event.verified = false

        candidate_event.mark_completed(true, association_class_pair[0])

        expect(candidate_event.completed_date).to eq(@today)
        # rubocop:disable Layout/LineLength
        expect(candidate_event.verified).to eq(association_class_pair[1]), "Verification does not match for association #{association_class_pair[0]} expected: #{association_class_pair[1]}"
        # rubocop:enable Layout/LineLength
      end
    end

    it 'validated event will be uncompleted and unverified.' do
      candidate = FactoryBot.create(:candidate)
      event_key = BaptismalCertificate.event_key
      AppFactory.add_confirmation_event(event_key)
      candidate = Candidate.find_by(account_name: candidate.account_name)
      candidate_event = candidate.get_candidate_event(event_key)

      [[BaptismalCertificate, false], [CandidateSheet, true], [ChristianMinistry, true],
       [PickConfirmationName, false], [RetreatVerification, false], [SponsorCovenant, false]].each do |association_class_pair|
        candidate_event.completed_date = @today
        candidate_event.verified = true

        candidate_event.mark_completed(false, association_class_pair[0])

        expect(candidate_event.completed_date).to be_nil
        expected_msg = "Verification does not match for association #{association_class_pair[0]} expected: false"
        expect(candidate_event.verified).to be(false), expected_msg
      end
    end

    it 'validated event will be uncompleted and unverified. 2' do
      candidate = FactoryBot.create(:candidate)
      event_key = BaptismalCertificate.event_key
      AppFactory.add_confirmation_event(event_key)
      candidate = Candidate.find_by(account_name: candidate.account_name)
      candidate_event = candidate.get_candidate_event(event_key)

      [[BaptismalCertificate, false], [CandidateSheet, true], [ChristianMinistry, true],
       [PickConfirmationName, false], [RetreatVerification, false], [SponsorCovenant, false]].each do |association_class_pair|
        candidate_event.completed_date = nil
        candidate_event.verified = false
        candidate_event.mark_completed(false, association_class_pair[0])

        expect(candidate_event.completed_date).to be_nil
        expected_msg = "Verification does not match for association #{association_class_pair[0]} expected: false"
        expect(candidate_event.verified).to be(false), expected_msg
      end
    end
  end
end
