# frozen_string_literal: true

describe PluckCan do
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

    it 'be late for program_year 2' do
      expect(@plucked_can.event_status(@cand_id,
                                       RetreatVerification.event_key,
                                       2)).to eq(I18n.t('status.late'))
    end

    it 'be coming due for program_year 1' do
      expect(@plucked_can.event_status(@cand_id,
                                       RetreatVerification.event_key,
                                       1)).to eq(I18n.t('status.coming_due'))
    end
  end
end
