# frozen_string_literal: true

describe PluckCanEvent do
  before do
    AppFactory.generate_default_status
    FactoryBot.create(:visitor)

    create_candidate_bap('c1', 'Paul')
    c2 = create_candidate_bap('c2_awaiting_admin', 'Vicki')
    c3 = create_candidate_bap('c3_no_completion_date', 'George')
    c4 = create_candidate_bap('c4_verified_true', 'George')
    AppFactory.add_confirmation_events
    # to see these events you have look up candidate
    # Candidate.find_by(account_name: @c1.account_name)
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

  it 'pluck all events' do
    pluck_candidate_events = PluckCanEvent.pluck_cand_events
    expect(pluck_candidate_events.size).to be(4)

    events = pluck_candidate_events[@c2.id]
    expect(events.size).to be(9)
    bap_certificate_event = events.find { |event| event.event_key == BaptismalCertificate.event_key }
    expect_awaiting_admin(bap_certificate_event, true)

    events = pluck_candidate_events[@c3.id]
    expect(events.size).to be(9)
    bap_certificate_event = events.find { |event| event.event_key == BaptismalCertificate.event_key }
    expect_awaiting_admin(bap_certificate_event, false)
  end

  it 'pluck awaiting_admin? events' do
    pluck_candidate_events = PluckCanEvent.pluck_awaiting_admin_cand_events
    expect(pluck_candidate_events.size).to be(1)
    expect(pluck_candidate_events[@c2.id].size).to be(1)
    pluck_candidate_event = pluck_candidate_events[@c2.id][0]
    expect_awaiting_admin(pluck_candidate_event, true)
  end

  private

  def create_candidate_bap(account_name, first)
    c1 = FactoryBot.create(:candidate, account_name: account_name)
    c1.candidate_sheet.first_name = first
    c1.candidate_sheet.last_name = 'Kristoff'
    c1.save
    c1
  end

  def expect_awaiting_admin(bap_certificate_event, awaiting_admin)
    expect(bap_certificate_event.event_key).to eq(BaptismalCertificate.event_key)
    expect(CandidateEvent.awaiting_admin?(bap_certificate_event.program_year1_due_date,
                                          bap_certificate_event.completed_date,
                                          bap_certificate_event.verified)).to eq(awaiting_admin)
  end
end
