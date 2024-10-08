# frozen_string_literal: true

describe ApplicationController do
  index = 0
  describe 'event_class' do
    context 'when confirmation due_date not set' do
      let(:confirmation_event) do
        FactoryBot.create(:confirmation_event, program_year1_due_date: nil, program_year2_due_date: nil)
      end

      it 'always return event-unitialized' do
        AppFactory.generate_default_status if Status.count == 0
        candidate = FactoryBot.create(:candidate)
        candidate_event = candidate.add_candidate_event(confirmation_event)
        expect(controller.event_class(candidate_event)).to eq('event-unitialized')
      end
    end

    context 'when confirmation due_date is set' do
      AppFactory.generate_default_status if Status.count == 0
      index += 1 while Candidate.find_by(account_name: "bar_#{index}")

      candidate = FactoryBot.create(:candidate, account_name: "bar_#{index}")
      today = Time.zone.today
      let(:confirmation_event_no_due_date) do
        FactoryBot.create(:confirmation_event, program_year1_due_date: nil, program_year2_due_date: nil)
      end
      let(:confirmation_event_today) do
        FactoryBot.create(:confirmation_event, program_year1_due_date: today, program_year2_due_date: today)
      end
      let(:confirmation_event_today_plus40) do
        FactoryBot.create(:confirmation_event, program_year1_due_date: today + 40, program_year2_due_date: today + 40)
      end
      let(:confirmation_event_today_minus40) do
        FactoryBot.create(:confirmation_event, program_year1_due_date: today - 40, program_year2_due_date: today - 40)
      end
      let(:candidate_event_not_completed_no_due_date) do
        create_candidate_event(candidate, nil, false, confirmation_event_no_due_date)
      end
      let(:candidate_event_not_completed_today) do
        create_candidate_event(candidate, nil, false, confirmation_event_today)
      end
      let(:candidate_event_not_completed_today_plus40) do
        create_candidate_event(candidate, nil, false, confirmation_event_today_plus40)
      end
      let(:candidate_event_not_completed_today_minus40) do
        create_candidate_event(candidate, nil, false, confirmation_event_today_minus40)
      end
      let(:candidate_event_not_verified_no_due_date) do
        create_candidate_event(candidate, today, false, confirmation_event_no_due_date)
      end
      let(:candidate_event_not_verified_today) do
        create_candidate_event(candidate, today, false, confirmation_event_today)
      end
      let(:candidate_event_not_verified_today_plus40) do
        create_candidate_event(candidate, today, false, confirmation_event_today_plus40)
      end
      let(:candidate_event_not_verified_today_minus40) do
        create_candidate_event(candidate, today, false, confirmation_event_today_minus40)
      end
      let(:candidate_event_completed_no_due_date) do
        create_candidate_event(candidate, today, true, confirmation_event_no_due_date)
      end
      let(:candidate_event_completed_today) do
        create_candidate_event(candidate, today, true, confirmation_event_today)
      end
      let(:candidate_event_completed_today_plus40) do
        create_candidate_event(candidate, today, true, confirmation_event_today_plus40)
      end
      let(:candidate_event_completed_today_minus40) do
        create_candidate_event(candidate, today, true, confirmation_event_today_minus40)
      end

      it 'always return event-awaiting-candidate' do
        expect(controller.event_class(candidate_event_not_completed_no_due_date)).to eq('event-unitialized')
        expect(controller.event_class(candidate_event_not_completed_today)).to eq('event-coming-due')
        expect(controller.event_class(candidate_event_not_completed_today_plus40)).to eq('event-awaiting-candidate')
        expect(controller.event_class(candidate_event_not_completed_today_minus40)).to eq('event-late')

        expect(controller.event_class(candidate_event_not_verified_no_due_date)).to eq('event-unitialized')
        expect(controller.event_class(candidate_event_not_verified_today)).to eq('event-awaiting-verification')
        expect(controller.event_class(candidate_event_not_verified_today_plus40)).to eq('event-awaiting-verification')
        expect(controller.event_class(candidate_event_not_verified_today_minus40)).to eq('event-awaiting-verification')

        expect(controller.event_class(candidate_event_completed_no_due_date)).to eq('event-unitialized')
        expect(controller.event_class(candidate_event_completed_today)).to eq('event-completed')
        expect(controller.event_class(candidate_event_completed_today_plus40)).to eq('event-completed')
        expect(controller.event_class(candidate_event_completed_today_minus40)).to eq('event-completed')
      end
    end
  end

  context 'with sorting' do
    it 'return a direction' do
      expect(controller.sort_direction(nil)).to eq('asc')
      expect(controller.sort_direction('xxx')).to eq('asc')
      expect(controller.sort_direction('asc')).to eq('asc')
      expect(controller.sort_direction('desc')).to eq('desc')
    end

    it 'return a column' do
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

  context 'when candidates_info' do
    before do
      AppFactory.generate_default_status
      @c3 = create_candidate('c3')
      @c2 = create_candidate('c2')
      @c1 = create_candidate('c1')
    end

    it 'sort (direction: :asc, sort: :account_name) by default' do
      controller.candidates_info
      expect(controller.candidate_info.size).to eq(3)
      expect(controller.candidate_info[0].account_name).to eq(@c1.account_name)
      expect(controller.candidate_info[1].account_name).to eq(@c2.account_name)
      expect(controller.candidate_info[2].account_name).to eq(@c3.account_name)
    end

    it 'sort (direction: :desc, sort: :account_name)' do
      controller.candidates_info(direction: :desc, sort: :account_name)
      expect(controller.candidate_info.size).to eq(3)
      expect(controller.candidate_info[0].account_name).to eq(@c3.account_name)
      expect(controller.candidate_info[1].account_name).to eq(@c2.account_name)
      expect(controller.candidate_info[2].account_name).to eq(@c1.account_name)
    end

    it 'sort (sort: :candidate_sheets.middle_name)' do
      controller.candidates_info(sort: :'candidate_sheets.middle_name')
      expect(controller.candidate_info.size).to eq(3)
      expect(controller.candidate_info[0].account_name).to eq(@c1.account_name)
      expect(controller.candidate_info[1].account_name).to eq(@c2.account_name)
      expect(controller.candidate_info[2].account_name).to eq(@c3.account_name)
    end

    it 'sort (direction: :desc, sort: :candidate_sheets.last_name)' do
      controller.candidates_info(direction: :desc, sort: :'candidate_sheets.last_name')
      expect(controller.candidate_info.size).to eq(3)
      expect(controller.candidate_info[0].account_name).to eq(@c1.account_name)
      expect(controller.candidate_info[1].account_name).to eq(@c3.account_name)
      expect(controller.candidate_info[2].account_name).to eq(@c2.account_name)
    end
  end

  private

  def create_candidate(prefix)
    candidate = FactoryBot.create(:candidate, account_name: prefix)
    case prefix
    when 'c1'
      candidate.candidate_sheet.first_name = 'c2first_name'
      candidate.candidate_sheet.middle_name = 'c1middle_name'
      candidate.candidate_sheet.last_name = 'c3last_name'
    when 'c2'
      candidate.candidate_sheet.first_name = 'c3first_name'
      candidate.candidate_sheet.middle_name = 'c2middle_name'
      candidate.candidate_sheet.last_name = 'c1last_name'
    when 'c3'
      candidate.candidate_sheet.first_name = 'c1first_name'
      candidate.candidate_sheet.middle_name = 'c3middle_name'
      candidate.candidate_sheet.last_name = 'c2last_name'
    else
      raise 'unknown prefix'
    end
    candidate.save
    candidate
  end

  def create_candidate_event(candidate, completed_date, verified, confirmation_event)
    candidate.candidate_events.clear
    candidate_event = candidate.add_candidate_event(confirmation_event)
    candidate_event.completed_date = completed_date
    candidate_event.verified = verified
    candidate_event
  end
end
