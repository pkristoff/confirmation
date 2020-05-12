# frozen_string_literal: true

describe ApplicationController do
  index = 0
  describe 'event_class' do
    context 'confirmation due_date not set' do
      let(:confirmation_event) { FactoryBot.create(:confirmation_event, the_way_due_date: nil, chs_due_date: nil) }
      it 'should always return event-unitialized' do
        candidate = FactoryBot.create(:candidate)
        candidate_event = candidate.add_candidate_event(confirmation_event)
        expect(controller.event_class(candidate_event)).to eq('event-unitialized')
      end
    end

    context 'confirmation due_date is set' do
      index += 1 while Candidate.find_by(account_name: "bar_#{index}")

      candidate = FactoryBot.create(:candidate, account_name: "bar_#{index}")
      let(:confirmation_event_no_due_date) { FactoryBot.create(:confirmation_event, the_way_due_date: nil, chs_due_date: nil) }
      today = Time.zone.today
      let(:confirmation_event_today) do
        FactoryBot.create(:confirmation_event, the_way_due_date: today, chs_due_date: today)
      end
      let(:confirmation_event_today_plus_40) do
        FactoryBot.create(:confirmation_event, the_way_due_date: today + 40, chs_due_date: today + 40)
      end
      let(:confirmation_event_today_minus_40) do
        FactoryBot.create(:confirmation_event, the_way_due_date: today - 40, chs_due_date: today - 40)
      end

      let(:candidate_event_not_completed_no_due_date) do
        create_candidate_event(candidate, nil, false, confirmation_event_no_due_date)
      end
      let(:candidate_event_not_completed_today) do
        create_candidate_event(candidate, nil, false, confirmation_event_today)
      end
      let(:candidate_event_not_completed_today_plus_40) do
        create_candidate_event(candidate, nil, false, confirmation_event_today_plus_40)
      end
      let(:candidate_event_not_completed_today_minus_40) do
        create_candidate_event(candidate, nil, false, confirmation_event_today_minus_40)
      end

      let(:candidate_event_not_verified_no_due_date) do
        create_candidate_event(candidate, today, false, confirmation_event_no_due_date)
      end
      let(:candidate_event_not_verified_today) do
        create_candidate_event(candidate, today, false, confirmation_event_today)
      end
      let(:candidate_event_not_verified_today_plus_40) do
        create_candidate_event(candidate, today, false, confirmation_event_today_plus_40)
      end
      let(:candidate_event_not_verified_today_minus_40) do
        create_candidate_event(candidate, today, false, confirmation_event_today_minus_40)
      end

      let(:candidate_event_completed_no_due_date) do
        create_candidate_event(candidate, today, true, confirmation_event_no_due_date)
      end
      let(:candidate_event_completed_today) do
        create_candidate_event(candidate, today, true, confirmation_event_today)
      end
      let(:candidate_event_completed_today_plus_40) do
        create_candidate_event(candidate, today, true, confirmation_event_today_plus_40)
      end
      let(:candidate_event_completed_today_minus_40) do
        create_candidate_event(candidate, today, true, confirmation_event_today_minus_40)
      end

      it 'should always return event-awaiting-candidate' do
        expect(controller.event_class(candidate_event_not_completed_no_due_date)).to eq('event-unitialized')
        expect(controller.event_class(candidate_event_not_completed_today)).to eq('event-coming-due')
        expect(controller.event_class(candidate_event_not_completed_today_plus_40)).to eq('event-awaiting-candidate')
        expect(controller.event_class(candidate_event_not_completed_today_minus_40)).to eq('event-late')

        expect(controller.event_class(candidate_event_not_verified_no_due_date)).to eq('event-unitialized')
        expect(controller.event_class(candidate_event_not_verified_today)).to eq('event-awaiting-verification')
        expect(controller.event_class(candidate_event_not_verified_today_plus_40)).to eq('event-awaiting-verification')
        expect(controller.event_class(candidate_event_not_verified_today_minus_40)).to eq('event-awaiting-verification')

        expect(controller.event_class(candidate_event_completed_no_due_date)).to eq('event-unitialized')
        expect(controller.event_class(candidate_event_completed_today)).to eq('event-completed')
        expect(controller.event_class(candidate_event_completed_today_plus_40)).to eq('event-completed')
        expect(controller.event_class(candidate_event_completed_today_minus_40)).to eq('event-completed')
      end
    end
  end

  context 'sorting' do
    it 'should return a direction' do
      expect(controller.sort_direction(nil)).to eq('asc')
      expect(controller.sort_direction('xxx')).to eq('asc')
      expect(controller.sort_direction('asc')).to eq('asc')
      expect(controller.sort_direction('desc')).to eq('desc')
    end

    it 'should return a column' do
      expect(controller.sort_column(nil)).to eq('account_name')
      expect(controller.sort_column('xxx')).to eq('account_name')
      expect(controller.sort_column('candidate_sheet.xxx')).to eq('account_name')
      expect(controller.sort_column('candidate_sheet.first_name')).to eq('candidate_sheet.first_name')
      expect(controller.sort_column('candidate_sheet.middle_name')).to eq('candidate_sheet.middle_name')
      expect(controller.sort_column('candidate_sheet.last_name')).to eq('candidate_sheet.last_name')
      expect(controller.sort_column('candidate_sheet.candidate_email')).to eq('candidate_sheet.candidate_email')
      expect(controller.sort_column('candidate_sheet.parent_email_1')).to eq('candidate_sheet.parent_email_1')
      expect(controller.sort_column('candidate_sheet.parent_email_2')).to eq('candidate_sheet.parent_email_2')
      expect(controller.sort_column('candidate_sheet.grade')).to eq('candidate_sheet.grade')
      expect(controller.sort_column('candidate_sheet.program_year')).to eq('candidate_sheet.program_year')
      expect(controller.sort_column('candidate_sheet.attending')).to eq('candidate_sheet.attending')
    end
  end

  def create_candidate_event(candidate, completed_date, verified, confirmation_event)
    candidate.candidate_events.clear
    candidate_event = candidate.add_candidate_event(confirmation_event)
    candidate_event.completed_date = completed_date
    candidate_event.verified = verified
    candidate_event
  end
end
