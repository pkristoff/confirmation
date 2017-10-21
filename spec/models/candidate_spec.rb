include ActionDispatch::TestProcess
describe Candidate do

  describe 'address' do

    it 'can retrieve a candiadate\'s address' do
      candidate = FactoryGirl.create(:candidate)
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
      expect(candidate.candidate_sheet.address.city).to match 'Apex'
      expect(candidate.candidate_sheet.address.state).to match 'NC'
      expect(candidate.candidate_sheet.address.zip_code).to match '27502'

      expect(candidate.candidate_events.size).to eq 0
    end

    it 'baptized_at_stmm' do
      candidate = AppFactory.create_candidate
      expect(candidate.baptized_at_stmm).to eq(false)
    end

  end

  describe 'candidate_events_sorted' do
    before(:each) do
      @candidates_with_data = [
          {candidate: setup_candidate(
              []),
           result: []
          },
          {candidate: setup_candidate(
              [
                  {name: 'a', the_way_due_date: nil, chs_due_date: nil, completed_date: nil}
              ]),
           result: %w(a)
          },
          {candidate: setup_candidate(
              [
                  {name: 'a', the_way_due_date: nil, chs_due_date: nil, completed_date: nil},
                  {name: 'b', the_way_due_date: nil, chs_due_date: nil, completed_date: nil}
              ]),
           result: %w(a b)
          },
          {candidate: setup_candidate(
              [
                  {name: 'a', the_way_due_date: '2016-05-01', chs_due_date: '2016-05-01', completed_date: nil},
                  {name: 'b', the_way_due_date: nil, chs_due_date: nil, completed_date: nil}
              ]),
           result: %w(b a)
          },
          {candidate: setup_candidate(
              [
                  {name: 'a', the_way_due_date: '2016-05-01', chs_due_date: '2016-05-01', completed_date: nil},
                  {name: 'b', the_way_due_date: '2016-05-01', chs_due_date: '2016-05-01', completed_date: nil}
              ]),
           result: %w(a b)
          },
          {candidate: setup_candidate(
              [
                  {name: 'a', the_way_due_date: '2016-05-01', chs_due_date: '2016-05-01', completed_date: nil},
                  {name: 'b', the_way_due_date: '2016-05-02', chs_due_date: '2016-05-02', completed_date: nil}
              ]),
           result: %w(a b)
          },
          {candidate: setup_candidate(
              [
                  {name: 'a', the_way_due_date: '2016-05-02', chs_due_date: '2016-05-02', completed_date: nil},
                  {name: 'b', the_way_due_date: '2016-05-01', chs_due_date: '2016-05-01', completed_date: nil}
              ]),
           result: %w(b a)
          },
          {candidate: setup_candidate(
              [
                  {name: 'a', the_way_due_date: '2016-05-01', chs_due_date: '2016-05-01', completed_date: '2016-05-05'},
                  {name: 'b', the_way_due_date: '2016-05-01', chs_due_date: '2016-05-01', completed_date: nil}
              ]),
           result: %w(b a)
          },
          {candidate: setup_candidate(
              [
                  {name: 'a', the_way_due_date: '2016-05-01', chs_due_date: '2016-05-01', completed_date: nil},
                  {name: 'b', the_way_due_date: '2016-05-01', chs_due_date: '2016-05-01', completed_date: '2016-05-05'}
              ]),
           result: %w(a b)
          },
          {candidate: setup_candidate(
              [
                  {name: 'a', the_way_due_date: '2016-05-01', chs_due_datechs_due_date: '2016-05-01', completed_date: '2016-05-06'},
                  {name: 'b', the_way_due_date: '2016-05-01', chs_due_date: '2016-05-01', completed_date: '2016-05-05'}
              ]),
           result: %w(a b)
          },
          {candidate: setup_candidate(
              [
                  {name: 'a', the_way_due_date: '2016-05-01', chs_due_date: '2016-05-01', completed_date: '2016-05-06'},
                  {name: 'b', the_way_due_date: '2016-05-02', chs_due_date: '2016-05-02', completed_date: '2016-05-05'}
              ]),
           result: %w(a b)
          },
          {candidate: setup_candidate(
              [
                  {name: 'a', the_way_due_date: '2016-05-02', chs_due_date: '2016-05-02', completed_date: '2016-05-06'},
                  {name: 'b', the_way_due_date: '2016-05-01', chs_due_date: '2016-05-01', completed_date: '2016-05-05'}
              ]),
           result: %w(b a)
          }
      ]
      end

      it 'two candidate_event with all nil' do
        @candidates_with_data.each do | data |
          candidate = data[:candidate]
          result = data[:result]
          expect(candidate.candidate_events.size).to eq(result.size)

          candidate_events_sorted = candidate.candidate_events_sorted

          expect(candidate_events_sorted.size).to eq(result.size)
          result.each_with_index { |expected_name, index | expect(candidate_events_sorted[index].name).to eq(expected_name) }

        end

    end

    it 'should create sponsor_covenant and pick_confirmation_name' do
      candidate = Candidate.new
      expect(candidate.sponsor_covenant).not_to eq(nil)
      expect(candidate.pick_confirmation_name).not_to eq(nil)
    end

    def setup_candidate(data)
      candidate = Candidate.new
      data.each do | candidate_data |
        confirmation_event = FactoryGirl.create(
            :confirmation_event,
            name: candidate_data[:name],
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
    it "should delete associations when deleted" do
      candidate = FactoryGirl.create(:candidate)

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

      c1 = create_candidate('c1', 'Paul', 'Kristoff')
      c2 = create_candidate('c2', 'Vicki', 'Kristoff')
      c3 = create_candidate('c3', 'Karen', 'Kristoff')

      AppFactory.add_confirmation_events

      @c1 = Candidate.find_by_account_name(c1.account_name)
      @c2 = Candidate.find_by_account_name(c2.account_name)
      @c3 = Candidate.find_by_account_name(c3.account_name)
    end

    it "baptismal_external_verification?" do
      event_key = I18n.t('events.baptismal_certificate')
      today = Date.today
      @c1.baptized_at_stmm = false
      @c1.get_candidate_event(event_key).completed_date = today
      @c1.save
      @c2.baptized_at_stmm = true
      @c2.get_candidate_event(event_key).completed_date = today
      @c2.save
      @c3.baptized_at_stmm = true
      @c3.get_candidate_event(event_key).completed_date = nil
      @c3.save

      expect(Candidate.baptismal_external_verification?(@c1)).to eq(false)
      expect(Candidate.baptismal_external_verification?(@c2)).to eq(true)
      expect(Candidate.baptismal_external_verification?(@c3)).to eq(nil)

    end

    it "retreat_external_verification??" do
      event_key = I18n.t('events.retreat_verification')
      today = Date.today
      @c1.retreat_verification.retreat_held_at_stmm = false
      @c1.get_candidate_event(event_key).completed_date = today
      @c1.save
      @c2.retreat_verification.retreat_held_at_stmm = true
      @c2.get_candidate_event(event_key).completed_date = today
      @c2.save
      @c3.retreat_verification.retreat_held_at_stmm = true
      @c3.get_candidate_event(event_key).completed_date = nil
      @c3.save

      expect(Candidate.retreat_external_verification?(@c1)).to eq(false)
      expect(Candidate.retreat_external_verification?(@c2)).to eq(true)
      expect(Candidate.retreat_external_verification?(@c3)).to eq(nil)

    end

    it "sponsor_external_verification?" do
      event_key = I18n.t('events.sponsor_covenant')
      today = Date.today
      @c1.sponsor_covenant.sponsor_attends_stmm = false
      @c1.get_candidate_event(event_key).completed_date = today
      @c1.save
      @c2.sponsor_covenant.sponsor_attends_stmm = true
      @c2.get_candidate_event(event_key).completed_date = today
      @c2.save
      @c3.sponsor_covenant.sponsor_attends_stmm = true
      @c3.get_candidate_event(event_key).completed_date = nil
      @c3.save

      expect(Candidate.sponsor_external_verification?(@c1)).to eq(false)
      expect(Candidate.sponsor_external_verification?(@c2)).to eq(true)
      expect(Candidate.sponsor_external_verification?(@c3)).to eq(nil)

    end
  end

  describe 'password' do

    it 'should return false if password is not initial password' do

      c1 = create_candidate('c1', 'Paul', 'Kristoff')
      c1.password = 'abcdefghij'
      expect(c1.password_changed?).to eq(true)
    end

    it 'should return false if password is initial password' do

      c1 = create_candidate('c1', 'Paul', 'Kristoff')
      c1.password = Event::Other::INITIAL_PASSWORD
      expect(c1.password_changed?).to eq(false)
    end

    it 'should return true if password is changed back to initial password' do

      c1 = create_candidate('c1', 'Paul', 'Kristoff')
      c1.password = 'abcdefghij'
      expect(c1.password_changed?).to eq(true)
      c1.password = Event::Other::INITIAL_PASSWORD
    end

  end

  describe 'confirm_account' do
    it 'should confirm an unconfirmed account' do
      candidate = FactoryGirl.create(:candidate, should_confirm: false)
      expect(candidate.account_confirmed?).to eq(false)
      candidate.confirm_account
      expect(candidate.account_confirmed?).to eq(true)
    end
    it 'should confirm a confirmed account' do
      candidate = FactoryGirl.create(:candidate, should_confirm: true)
      expect(candidate.account_confirmed?).to eq(true)
      candidate.confirm_account
      expect(candidate.account_confirmed?).to eq(true)
    end
    it 'should confirm a confirmed account that started not confirmed' do
      candidate = FactoryGirl.create(:candidate, should_confirm: false)
      expect(candidate.account_confirmed?).to eq(false)
      candidate.confirm_account
      candidate.confirm_account
      expect(candidate.account_confirmed?).to eq(true)
    end
  end

  describe 'password_reset_message' do
    it 'should return a DeliveryMessage' do
      c1 = create_candidate('c1', 'Paul', 'Kristoff')
      delivery = c1.password_reset_message
      expect(delivery).not_to eq(nil)
      text = delivery.message.body.to_s

      expect(text).not_to eq(nil)
      expect(text.include? 'Hello c1!').to eq(true)
      expect(text.include? 'Your Username is: c1').to eq(true)
    end
  end

  def create_candidate(account_name, first, last)
    candidate = FactoryGirl.create(:candidate, account_name: account_name)
    candidate.candidate_sheet.first_name = first
    candidate.candidate_sheet.last_name = last
    candidate.save
    candidate
  end

  def expect_event_association(assoc_from_candidate, size)
    event_assoc = assoc_from_candidate.class.all
    expect(event_assoc.size).to eq(size)
    expect(assoc_from_candidate).to eq(event_assoc.first) if size === 1
  end

end
