# frozen_string_literal: true

describe Candidate do
  include ActionDispatch::TestProcess

  before(:each) do
    @today = Time.zone.today
  end

  describe 'candidate_note' do
    it 'can retrieve candidate_note' do
      candidate = FactoryBot.create(:candidate)

      expect(candidate.candidate_note).to match 'Admin note'
    end
  end

  describe 'address' do
    it 'can retrieve a candiadate\'s address' do
      candidate = FactoryBot.create(:candidate)
      expect(candidate.account_name).to match 'sophiaagusta'
      expect(candidate.candidate_sheet.parent_email_1).to match 'test@example.com'

      expect(candidate.candidate_sheet.address.street_1).to match '2120 Frissell Ave.'
      expect(candidate.candidate_sheet.address.street_2).to match 'Apt. 456'
      expect(candidate.candidate_sheet.address.city).to match 'Apex'
      expect(candidate.candidate_sheet.address.state).to match 'NC'
      expect(candidate.candidate_sheet.address.zip_code).to match '27502'

      expect(candidate.candidate_events.size).to eq 2
    end

    it 'can retrieve a new candiadate\'s address' do
      candidate = Candidate.new
      expect(candidate.account_name).to match ''
      expect(candidate.candidate_sheet.parent_email_1).to match ''

      expect(candidate.candidate_sheet.address.street_1).to match ''
      expect(candidate.candidate_sheet.address.street_2).to match ''
      expect(candidate.candidate_sheet.address.city).to match ''
      expect(candidate.candidate_sheet.address.state).to match ''
      expect(candidate.candidate_sheet.address.zip_code).to match ''

      expect(candidate.candidate_events.size).to eq 0
    end

    it 'baptized_at_home_parish' do
      candidate = AppFactory.create_candidate
      expect(candidate.baptismal_certificate.baptized_at_home_parish).to eq(false)
    end
  end

  describe 'candidate_events_sorted' do
    before(:each) do
      @candidates_with_data = [
        { candidate: setup_candidate(
          []
        ),
          result: [] },
        { candidate: setup_candidate(
          [
            { event_key: 'a', the_way_due_date: nil, chs_due_date: nil, completed_date: nil }
          ]
        ),
          result: %w[a] },
        { candidate: setup_candidate(
          [
            { event_key: 'a', the_way_due_date: nil, chs_due_date: nil, completed_date: nil },
            { event_key: 'b', the_way_due_date: nil, chs_due_date: nil, completed_date: nil }
          ]
        ),
          result: %w[a b] },
        { candidate: setup_candidate(
          [
            { event_key: 'a', the_way_due_date: '2016-05-01', chs_due_date: '2016-05-01', completed_date: nil },
            { event_key: 'b', the_way_due_date: nil, chs_due_date: nil, completed_date: nil }
          ]
        ),
          result: %w[b a] },
        { candidate: setup_candidate(
          [
            { event_key: 'a', the_way_due_date: '2016-05-01', chs_due_date: '2016-05-01', completed_date: nil },
            { event_key: 'b', the_way_due_date: '2016-05-01', chs_due_date: '2016-05-01', completed_date: nil }
          ]
        ),
          result: %w[a b] },
        { candidate: setup_candidate(
          [
            { event_key: 'a', the_way_due_date: '2016-05-01', chs_due_date: '2016-05-01', completed_date: nil },
            { event_key: 'b', the_way_due_date: '2016-05-02', chs_due_date: '2016-05-02', completed_date: nil }
          ]
        ),
          result: %w[a b] },
        { candidate: setup_candidate(
          [
            { event_key: 'a', the_way_due_date: '2016-05-02', chs_due_date: '2016-05-02', completed_date: nil },
            { event_key: 'b', the_way_due_date: '2016-05-01', chs_due_date: '2016-05-01', completed_date: nil }
          ]
        ),
          result: %w[b a] },
        { candidate: setup_candidate(
          [
            { event_key: 'a', the_way_due_date: '2016-05-01', chs_due_date: '2016-05-01', completed_date: '2016-05-05' },
            { event_key: 'b', the_way_due_date: '2016-05-01', chs_due_date: '2016-05-01', completed_date: nil }
          ]
        ),
          result: %w[b a] },
        { candidate: setup_candidate(
          [
            { event_key: 'a', the_way_due_date: '2016-05-01', chs_due_date: '2016-05-01', completed_date: nil },
            { event_key: 'b', the_way_due_date: '2016-05-01', chs_due_date: '2016-05-01', completed_date: '2016-05-05' }
          ]
        ),
          result: %w[a b] },
        { candidate: setup_candidate(
          [
            { event_key: 'a', the_way_due_date: '2016-05-01',
              chs_due_datechs_due_date: '2016-05-01', completed_date: '2016-05-06' },
            { event_key: 'b', the_way_due_date: '2016-05-01', chs_due_date: '2016-05-01', completed_date: '2016-05-05' }
          ]
        ),
          result: %w[a b] },
        { candidate: setup_candidate(
          [
            { event_key: 'a', the_way_due_date: '2016-05-01', chs_due_date: '2016-05-01', completed_date: '2016-05-06' },
            { event_key: 'b', the_way_due_date: '2016-05-02', chs_due_date: '2016-05-02', completed_date: '2016-05-05' }
          ]
        ),
          result: %w[a b] },
        { candidate: setup_candidate(
          [
            { event_key: 'a', the_way_due_date: '2016-05-02', chs_due_date: '2016-05-02', completed_date: '2016-05-06' },
            { event_key: 'b', the_way_due_date: '2016-05-01', chs_due_date: '2016-05-01', completed_date: '2016-05-05' }
          ]
        ),
          result: %w[b a] }
      ]
    end

    it 'two candidate_event with all nil' do
      @candidates_with_data.each do |data|
        candidate = data[:candidate]
        result = data[:result]
        expect(candidate.candidate_events.size).to eq(result.size)

        candidate_events_sorted = candidate.candidate_events_sorted

        expect(candidate_events_sorted.size).to eq(result.size)
        result.each_with_index { |expected_name, index| expect(candidate_events_sorted[index].event_key).to eq(expected_name) }
      end
    end

    it 'should create sponsor_covenant and pick_confirmation_name' do
      candidate = Candidate.new
      expect(candidate.sponsor_covenant).not_to eq(nil)
      expect(candidate.pick_confirmation_name).not_to eq(nil)
    end

    private

    def setup_candidate(data)
      candidate = Candidate.new
      data.each do |candidate_data|
        confirmation_event = FactoryBot.create(
          :confirmation_event,
          event_key: candidate_data[:event_key],
          the_way_due_date: (candidate_data[:the_way_due_date].nil? ? nil : Date.parse(candidate_data[:the_way_due_date])),
          chs_due_date: (candidate_data[:chs_due_date].nil? ? nil : Date.parse(candidate_data[:chs_due_date]))
        )
        candidate_event = candidate.add_candidate_event(confirmation_event)
        candidate_event.completed_date = candidate_data[:completed_date]
      end
      candidate
    end
  end

  describe 'delete associations' do
    it 'should delete associations when deleted' do
      candidate = FactoryBot.create(:candidate)

      expect_event_association(candidate.baptismal_certificate, 1)
      expect_event_association(candidate.candidate_sheet, 1)
      expect_event_association(candidate.sponsor_covenant, 1)
      expect_event_association(candidate.pick_confirmation_name, 1)
      expect_event_association(candidate.christian_ministry, 1)
      expect_event_association(candidate.retreat_verification, 1)
      expect_event_association(candidate.sponsor_covenant, 1)

      candidate.destroy

      expect_event_association(candidate.baptismal_certificate, 0)
      expect_event_association(candidate.candidate_sheet, 0)
      expect_event_association(candidate.sponsor_covenant, 0)
      expect_event_association(candidate.pick_confirmation_name, 0)
      expect_event_association(candidate.christian_ministry, 0)
      expect_event_association(candidate.retreat_verification, 0)
      expect_event_association(candidate.sponsor_covenant, 0)
    end
  end

  describe 'external verification' do
    before(:each) do
      c1 = create_candidate_local('c1', 'Paul', 'Kristoff')
      c2 = create_candidate_local('c2', 'Vicki', 'Kristoff')
      c3 = create_candidate_local('c3', 'Karen', 'Kristoff')
      c4 = create_candidate_local('c4', 'aaa', 'Kristoff')

      AppFactory.add_confirmation_events

      @c1 = Candidate.find_by(account_name: c1.account_name)
      @c2 = Candidate.find_by(account_name: c2.account_name)
      @c3 = Candidate.find_by(account_name: c3.account_name)
      @c4 = Candidate.find_by(account_name: c4.account_name)
    end

    it 'baptismal_external_verification?' do
      event_key = BaptismalCertificate.event_key
      @c1.baptismal_certificate.baptized_at_home_parish = false
      @c1.get_candidate_event(event_key).completed_date = @today
      @c1.save
      @c2.baptismal_certificate.baptized_at_home_parish = true
      @c2.get_candidate_event(event_key).completed_date = @today
      @c2.save
      @c3.baptismal_certificate.baptized_at_home_parish = true
      @c3.get_candidate_event(event_key).completed_date = nil
      @c3.save
      @c4.baptismal_certificate.baptized_at_home_parish = false
      @c4.get_candidate_event(event_key).completed_date = @today
      @c4.save

      expect_external_verification(Candidate.baptismal_external_verification, [@c2], [@c1, @c4], [], [@c3])
    end

    it 'confirmation_name_external_verification' do
      event_key = PickConfirmationName.event_key
      @c1.pick_confirmation_name.saint_name = 'xxx'
      @c1.get_candidate_event(event_key).completed_date = @today
      @c1.save
      @c2.pick_confirmation_name.saint_name = 'xxx'
      @c2.get_candidate_event(event_key).completed_date = @today
      @c2.get_candidate_event(event_key).verified = true
      @c2.save
      @c3.pick_confirmation_name.saint_name = nil
      @c3.save

      expect_external_verification(Candidate.confirmation_name_external_verification, [], [@c1], [@c2], [@c3, @c4])
    end

    def expect_external_verification(actual, external, to_be_verified, verified, not_complete)
      expect(actual[0]).to eq(external)
      expect(actual[1]).to eq(to_be_verified)
      expect(actual[2]).to eq(verified)
      expect(actual[3]).to eq(not_complete)
    end

    it 'retreat_external_verification?' do
      event_key = RetreatVerification.event_key
      @c1.retreat_verification.retreat_held_at_home_parish = false
      @c1.get_candidate_event(event_key).completed_date = @today
      @c1.save
      @c2.retreat_verification.retreat_held_at_home_parish = true
      @c2.get_candidate_event(event_key).completed_date = @today
      @c2.save
      @c3.retreat_verification.retreat_held_at_home_parish = true
      @c3.get_candidate_event(event_key).completed_date = nil
      @c3.save

      expect_external_verification(Candidate.retreat_external_verification, [@c2], [@c1], [], [@c3, @c4])
    end

    it 'sponsor_covenant_external_verification?' do
      event_key = SponsorCovenant.event_key
      @c1.sponsor_covenant.sponsor_name = ''
      @c1.get_candidate_event(event_key).completed_date = @today
      @c1.save
      @c2.sponsor_covenant.sponsor_name = 'George'
      @c2.get_candidate_event(event_key).completed_date = @today
      @c2.save
      @c3.sponsor_covenant.sponsor_name = 'Sam'
      @c3.get_candidate_event(event_key).completed_date = nil
      @c3.save

      expect_external_verification(Candidate.sponsor_covenant_external_verification, [], [@c1, @c2], [], [@c3, @c4])
    end

    it 'sponsor_eligibility_external_verification?' do
      event_key = SponsorEligibility.event_key
      @c1.sponsor_eligibility.sponsor_attends_home_parish = false
      @c1.get_candidate_event(event_key).completed_date = @today
      @c1.save
      @c2.sponsor_eligibility.sponsor_attends_home_parish = true
      @c2.get_candidate_event(event_key).completed_date = @today
      @c2.save
      @c3.sponsor_eligibility.sponsor_attends_home_parish = true
      @c3.get_candidate_event(event_key).completed_date = nil
      @c3.save

      expect_external_verification(Candidate.sponsor_eligibility_external_verification, [@c2], [@c1], [], [@c3, @c4])
    end
  end

  describe 'password' do
    it 'should return false if password is not initial password' do
      c1 = create_candidate_local('c1', 'Paul', 'Kristoff')
      c1.password = 'abcdefghij'
      expect(c1.password_changed?).to eq(true)
    end

    it 'should return false if password is initial password' do
      c1 = create_candidate_local('c1', 'Paul', 'Kristoff')
      c1.password = Event::Other::INITIAL_PASSWORD
      expect(c1.password_changed?).to eq(false)
    end

    it 'should return true if password is changed back to initial password' do
      c1 = create_candidate_local('c1', 'Paul', 'Kristoff')
      c1.password = 'abcdefghij'
      expect(c1.password_changed?).to eq(true)
      c1.password = Event::Other::INITIAL_PASSWORD
    end
  end

  describe 'confirm_account' do
    it 'should confirm an unconfirmed account' do
      candidate = FactoryBot.create(:candidate, should_confirm: false)
      expect(candidate.account_confirmed?).to eq(false)
      candidate.confirm_account
      expect(candidate.account_confirmed?).to eq(true)
    end
    it 'should confirm a confirmed account' do
      candidate = FactoryBot.create(:candidate, should_confirm: true)
      expect(candidate.account_confirmed?).to eq(true)
      candidate.confirm_account
      expect(candidate.account_confirmed?).to eq(true)
    end
    it 'should confirm a confirmed account that started not confirmed' do
      candidate = FactoryBot.create(:candidate, should_confirm: false)
      expect(candidate.account_confirmed?).to eq(false)
      candidate.confirm_account
      candidate.confirm_account
      expect(candidate.account_confirmed?).to eq(true)
    end
  end

  describe 'password_reset_message' do
    it 'should return a DeliveryMessage' do
      c1 = create_candidate_local('c1', 'Paul', 'Kristoff')
      delivery = c1.password_reset_message(
        FactoryBot.create(:admin),
        CandidatesMailerText.new(candidate: c1,
                                 subject: MailPart.new_subject('sub'),
                                 body_text: MailPart.new_body(''))
      )
      expect(delivery).not_to eq(nil)
      text = delivery.message.body.to_s

      expect(text).not_to eq(nil)
      expect(text.include?('Hello c1!')).to eq(true)
      expect(text.include?('Your Username is: c1')).to eq(true)
    end
  end

  describe 'genertate_account_name' do
    it 'combos' do
      expect(Candidate.genertate_account_name('', '')).to eq('')
      expect(Candidate.genertate_account_name('', 'First')).to eq('first')
      expect(Candidate.genertate_account_name('Last', '')).to eq('last')
      expect(Candidate.genertate_account_name('Last', 'First')).to eq('lastfirst')
    end
  end

  def create_candidate_local(account_name, first, last)
    candidate = FactoryBot.create(:candidate, account_name: account_name)
    candidate.candidate_sheet.first_name = first
    candidate.candidate_sheet.last_name = last
    candidate.save
    candidate
  end

  def expect_event_association(assoc_from_candidate, size)
    event_assoc = assoc_from_candidate.class.all
    expect(event_assoc.size).to eq(size)
    expect(assoc_from_candidate).to eq(event_assoc.first) if size == 1
  end
end
