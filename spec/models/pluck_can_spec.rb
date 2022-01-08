# frozen_string_literal: true

describe PluckCan, type: :model do
  before(:each) do
    AppFactory.add_confirmation_events
  end
  describe 'status' do
    before(:each) do
      @cand_id = 1
      fake_id = 99
      cand_info = []
      cand_event_info = {}
      cand_event_info[1] = cand_info
      cand_info << [@cand_id, fake_id, fake_id,
                    RetreatVerification.event_key, false, nil, Time.zone.today + 5, Time.zone.today - 5]
      @pluck_can = PluckCan.new(cand_info, cand_event_info)
    end
    it 'should be late for CATHOLIC_HIGH_SCHOOL' do
      expect(@pluck_can.status(@cand_id,
                               RetreatVerification.event_key, Candidate::CATHOLIC_HIGH_SCHOOL)).to eq(I18n.t('status.late'))
    end
    it 'should be coming due for THE_WAY' do
      expect(@pluck_can.status(@cand_id,
                               RetreatVerification.event_key, Candidate::THE_WAY)).to eq(I18n.t('status.coming_due'))
    end
  end
end
