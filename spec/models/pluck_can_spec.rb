# frozen_string_literal: true

describe PluckCan, type: :model do
  before do
    AppFactory.add_confirmation_events
  end

  describe 'status' do
    before do
      @cand_id = 1
      fake_id = 99
      plucked_can_event = []
      cand_event_info = {}
      cand_event_info[1] = plucked_can_event
      now = Time.zone.today
      cand_info = [@cand_id, fake_id, fake_id, RetreatVerification.event_key, false, nil, now + 5, now - 5]
      plucked_can_event << PluckCanEvent.new(cand_info)
      @plucked_can = PluckCan.new([@cand_id, 'c1', now, '', 'last', 'first', 10, 2, Candidate::THE_WAY],
                                  cand_event_info)
    end

    it 'be late for CATHOLIC_HIGH_SCHOOL' do
      expect(@plucked_can.status(@cand_id,
                                 RetreatVerification.event_key, Candidate::CATHOLIC_HIGH_SCHOOL)).to eq(I18n.t('status.late'))
    end

    it 'be coming due for THE_WAY' do
      expect(@plucked_can.status(@cand_id,
                                 RetreatVerification.event_key, Candidate::THE_WAY)).to eq(I18n.t('status.coming_due'))
    end
  end
end
