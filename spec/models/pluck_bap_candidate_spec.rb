# frozen_string_literal: true

describe PluckBapCandidate do
  before do
    AppFactory.add_confirmation_events
  end

  describe 'pluck_bap_candidate' do
    # require "get_process_mem"
    before do
      FactoryBot.create(:visitor)
      create_candidate_bap('c1', 'Paul')
      c3 = create_candidate_bap('c3_no_completion_date', 'Karen')
      c4 = create_candidate_bap('c4_verified_true', 'George')
      c2 = create_candidate_bap('c2_awaiting_admin', 'Vicki')
      AppFactory.add_confirmation_events
      # to see these events you have look up candidate
      # c1 = Candidate.find_by(account_name: @c1.account_name)
      @c2 = Candidate.find_by(account_name: c2.account_name)
      bap_event = @c2.get_candidate_event(BaptismalCertificate.event_key)
      bap_event.completed_date = Time.zone.today
      bap_event.verified = false
      bap_event.save

      @c3 = Candidate.find_by(account_name: c3.account_name)
      bap_event = @c3.get_candidate_event(BaptismalCertificate.event_key)
      bap_event.completed_date = nil
      bap_event.verified = false
      bap_event.save

      @c4 = Candidate.find_by(account_name: c4.account_name)
      bap_event = @c4.get_candidate_event(BaptismalCertificate.event_key)
      bap_event.completed_date = Time.zone.today
      bap_event.verified = true
      bap_event.save
    end

    it 'pluck_bap_candidate only has awaiting admin on baptsmal event' do
      expect(PluckBapCandidate.pluck_bap_candidates.size).to eq(1)
    end

    it 'pluck_bap_candidate sort by last_name & first_name' do
      c2 = Candidate.find_by(account_name: @c2.account_name)
      bap_event = c2.get_candidate_event(BaptismalCertificate.event_key)
      bap_event.completed_date = Time.zone.today
      bap_event.verified = false
      bap_event.save

      c3 = Candidate.find_by(account_name: @c3.account_name)
      bap_event = c3.get_candidate_event(BaptismalCertificate.event_key)
      bap_event.completed_date = Time.zone.today
      bap_event.verified = false
      bap_event.save

      c4 = Candidate.find_by(account_name: @c4.account_name)
      bap_event = c4.get_candidate_event(BaptismalCertificate.event_key)
      bap_event.completed_date = Time.zone.today
      bap_event.verified = false
      bap_event.save
      pluck_bap_candidates = PluckBapCandidate.pluck_bap_candidates

      expect(pluck_bap_candidates.size).to eq(3)
      expect(pluck_bap_candidates[0].first_name).to eq('George')
      expect(pluck_bap_candidates[1].first_name).to eq('Karen')
      expect(pluck_bap_candidates[2].first_name).to eq('Vicki')
    end
  end

  private

  def create_candidate_bap(account_name, first)
    c1 = FactoryBot.create(:candidate, account_name: account_name)
    c1.candidate_sheet.first_name = first
    c1.candidate_sheet.last_name = 'Kristoff'
    c1.save
    c1
  end
end
