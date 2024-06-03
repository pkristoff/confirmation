# frozen_string_literal: true

describe ResetDB do
  before do
    AppFactory.generate_default_status
    FactoryBot.create(:visitor)
  end

  describe 'start new year' do
    it 'start a new year will clean out candidates and all its associations' do
      FactoryBot.create(:admin, email: 'paul@kristoffs.com', name: 'Paul')
      AppFactory.add_confirmation_events

      expect(Admin.count).to eq(1)

      expect(Visitor.visitor.home_parish_address_id).not_to be_nil,
                                                            'Visitor address is missing.'

      expect_table_rows(Candidate, { Address: 1,
                                     BaptismalCertificate: 0,
                                     Candidate: 0,
                                     CandidateEvent: 0,
                                     CandidateSheet: 0,
                                     ChristianMinistry: 0,
                                     ConfirmationEvent: 9,
                                     PickConfirmationName: 0,
                                     RetreatVerification: 0,
                                     SponsorCovenant: 0,
                                     SponsorEligibility: 0,
                                     ScannedImage: 0,
                                     ToDo: 0 })

      c0 = FactoryBot.create(:candidate, add_new_confirmation_events: false)
      AppFactory.add_candidate_events(c0)
      c0.baptismal_certificate.scanned_certificate = create_scanned_image
      c0.retreat_verification.scanned_retreat = create_scanned_image
      c0.sponsor_covenant.scanned_covenant = create_scanned_image
      c0.sponsor_eligibility.scanned_eligibility = create_scanned_image
      c0.save

      c1 = FactoryBot.create(:candidate, account_name: 'c1', add_new_confirmation_events: false)
      AppFactory.add_candidate_events(c1)
      c1.save

      c2 = FactoryBot.create(:candidate, account_name: 'c2', add_new_confirmation_events: false)
      AppFactory.add_candidate_events(c2)
      c2.save

      expect(Admin.all.size).to eq(1)

      expect_table_rows(Candidate, { Address: 7,
                                     BaptismalCertificate: 3,
                                     Candidate: 3,
                                     CandidateEvent: 27,
                                     CandidateSheet: 3,
                                     ChristianMinistry: 3,
                                     ConfirmationEvent: 9,
                                     PickConfirmationName: 3,
                                     RetreatVerification: 3,
                                     SponsorCovenant: 3,
                                     SponsorEligibility: 3,
                                     ScannedImage: 4,
                                     ToDo: 27 })

      expect(Visitor.visitor.home_parish_address_id).not_to be_nil,
                                                            'Visitor address is missing.'

      ResetDB.start_new_year

      expect(Visitor.visitor.home_parish_address_id).not_to be_nil,
                                                            'Visitor address is missing.'

      expect(Admin.count).to eq(1)

      expect_table_rows(Candidate, { Address: 3,
                                     BaptismalCertificate: 1,
                                     Candidate: 1,
                                     CandidateEvent: 9,
                                     CandidateSheet: 1,
                                     ChristianMinistry: 1,
                                     ConfirmationEvent: 9,
                                     PickConfirmationName: 1,
                                     RetreatVerification: 1,
                                     SponsorCovenant: 1,
                                     SponsorEligibility: 1,
                                     ScannedImage: 0,
                                     ToDo: 9 })
    end

    it 'start a new year will clean up dangling references the DB' do
      FactoryBot.create(:admin, email: 'paul@kristoffs.com', name: 'Paul')
      AppFactory.add_confirmation_events

      expect(Admin.all.size).to eq(1)

      expect_table_rows(Candidate, { Address: 1,
                                     BaptismalCertificate: 0,
                                     Candidate: 0,
                                     CandidateEvent: 0,
                                     CandidateSheet: 0,
                                     ChristianMinistry: 0,
                                     ConfirmationEvent: 9,
                                     PickConfirmationName: 0,
                                     RetreatVerification: 0,
                                     SponsorCovenant: 0,
                                     SponsorEligibility: 0,
                                     ScannedImage: 0,
                                     ToDo: 0 })

      # create orphaned records - TODO: use get_association_classes
      FactoryBot.create(:address)
      FactoryBot.create(:baptismal_certificate)
      FactoryBot.create(:candidate_event)
      FactoryBot.create(:candidate_sheet)
      FactoryBot.create(:christian_ministry)
      FactoryBot.create(:pick_confirmation_name)
      FactoryBot.create(:retreat_verification)
      FactoryBot.create(:sponsor_covenant)
      FactoryBot.create(:sponsor_eligibility)
      FactoryBot.create(:to_do)
      FactoryBot.create(:scanned_image)

      reset_db = ResetDB.new

      c0 = FactoryBot.create(:candidate, add_new_confirmation_events: false)
      AppFactory.add_candidate_events(c0)
      c0.save
      c1 = FactoryBot.create(:candidate, account_name: 'c1', add_new_confirmation_events: false)
      AppFactory.add_candidate_events(c1)
      c1.baptismal_certificate.scanned_certificate = create_scanned_image
      c1.save
      c2 = FactoryBot.create(:candidate, account_name: 'c2', add_new_confirmation_events: false)
      AppFactory.add_candidate_events(c2)
      c2.save

      expect(Admin.count).to eq(1)

      expect_table_rows(Candidate, { Address: 10,
                                     BaptismalCertificate: 4,
                                     Candidate: 3,
                                     CandidateEvent: 28,
                                     CandidateSheet: 4,
                                     ChristianMinistry: 4,
                                     ConfirmationEvent: 9,
                                     PickConfirmationName: 4,
                                     RetreatVerification: 4,
                                     SponsorCovenant: 4,
                                     SponsorEligibility: 4,
                                     ScannedImage: 4,
                                     ToDo: 28 })

      reset_db.start_new_year
      expect(Admin.count).to eq(1)

      expect_table_rows(Candidate, { Address: 3, # 2 for seed + 1 for visitor
                                     BaptismalCertificate: 1,
                                     Candidate: 1,
                                     CandidateEvent: 9,
                                     CandidateSheet: 1,
                                     ChristianMinistry: 1,
                                     ConfirmationEvent: 9,
                                     PickConfirmationName: 1,
                                     RetreatVerification: 1,
                                     SponsorCovenant: 1,
                                     SponsorEligibility: 1,
                                     ScannedImage: 0,
                                     ToDo: 9 })
    end

    it 'start a new year will keep candidates in program_year == 1 and move candidate program_year to 2.' do
      active_cand_year1 = FactoryBot.create(:candidate, account_name: 'active_cand_year1')
      active_cand_year1.candidate_sheet.program_year = 1
      active_cand_year1.candidate_sheet.grade = 9
      active_cand_year1.save
      active_cand_year2 = FactoryBot.create(:candidate, account_name: 'active_cand_year2')
      active_cand_year2.candidate_sheet.program_year = 2
      cand_event_size = active_cand_year1.candidate_events.size
      expect(cand_event_size).to eq(ConfirmationEvent.count)
      active_cand_year2.save
      expect(Candidate.count).to eq(2)

      error_msg = "before candidate_events(#{cand_event_size}) does not match ConfirmationEvent(#{ConfirmationEvent.count})"
      expect(cand_event_size).to eq(ConfirmationEvent.count), error_msg

      ResetDB.start_new_year

      vicki_candidate = Candidate.find_by(account_name: 'vickikristoff')
      expect(vicki_candidate).not_to be_nil
      expect(vicki_candidate.candidate_events.size).to eq(ConfirmationEvent.count)

      # active_cand_year2 is removed
      active_cand_year2 = Candidate.find_by(id: active_cand_year2.id)
      expect(active_cand_year2).to be_nil

      # active_cand_year1 kept & moved to program year 2.
      active_cand_year1 = Candidate.find_by(id: active_cand_year1.id)
      expect(active_cand_year1.candidate_events).not_to be_nil
      cnt = ConfirmationEvent.count
      error_msg =
        "candidate_events(#{active_cand_year1.candidate_events.size}) does not match ConfirmationEvent(#{cnt})"
      expect(active_cand_year1.candidate_events.size).to eq(ConfirmationEvent.count), error_msg
      expect(active_cand_year1).not_to be_nil
      expect_cand_values(active_cand_year1, { program_year: 2,
                                              grade: 10 })
      expect_table_rows(Candidate, { Address: 3, # 2 for seed + 1 for visitor
                                     BaptismalCertificate: 2,
                                     Candidate: 2,
                                     CandidateEvent: 4,
                                     CandidateSheet: 2,
                                     ChristianMinistry: 2,
                                     ConfirmationEvent: 2,
                                     PickConfirmationName: 2,
                                     RetreatVerification: 2,
                                     SponsorCovenant: 2,
                                     SponsorEligibility: 2,
                                     ScannedImage: 0,
                                     ToDo: 4 })
    end

    it 'start a new year will keep candidates with status of Deferred.' do
      deferred_cand_year2 = FactoryBot.create(:candidate, account_name: 'deferred_cand_year2')
      deferred_cand_year2.candidate_sheet.program_year = 2
      deferred_cand_year2.status_id = Status.deferred.id
      deferred_cand_year2.save

      active_cand_year2 = FactoryBot.create(:candidate, account_name: 'active_cand_year2')
      active_cand_year2.candidate_sheet.program_year = 2
      active_cand_year2.status_id = Status.active.id
      active_cand_year2.save
      expect(Candidate.count).to eq(2)

      ResetDB.start_new_year

      vicki_candidate = Candidate.find_by(account_name: 'vickikristoff')
      expect(vicki_candidate).not_to be_nil

      # active_cand_year2 is removed
      active_cand_year2 = Candidate.find_by(account_name: 'active_cand_year2')
      expect(active_cand_year2).to be_nil

      # deferred_cand_year2 kept & moved to program year 2.
      deferred_cand_year2 = Candidate.find_by(account_name: 'deferred_cand_year2')
      expect(deferred_cand_year2).not_to be_nil
      expect_cand_values(deferred_cand_year2, { program_year: 2,
                                                grade: 11 })
      expect_table_rows(Candidate, { Address: 3, # 2 for seed + 1 for visitor
                                     BaptismalCertificate: 2,
                                     Candidate: 2,
                                     CandidateEvent: 4,
                                     CandidateSheet: 2,
                                     ChristianMinistry: 2,
                                     ConfirmationEvent: 2,
                                     PickConfirmationName: 2,
                                     RetreatVerification: 2,
                                     SponsorCovenant: 2,
                                     SponsorEligibility: 2,
                                     ScannedImage: 0,
                                     ToDo: 4 })
    end

    it 'start a new year will remove candidates with status of Getting Confirmed elsewhere.' do
      getting_confirmed_elsewhere = FactoryBot.create(:candidate, account_name: 'Getting_Confirmed_elsewhere_cand_year2')
      getting_confirmed_elsewhere.candidate_sheet.program_year = 2
      getting_confirmed_elsewhere.status_id = Status.confirmed_elsewhere.id
      getting_confirmed_elsewhere.save
      expect(Candidate.count).to eq(1)

      ResetDB.start_new_year

      vicki_candidate = Candidate.find_by(account_name: 'vickikristoff')
      expect(vicki_candidate).not_to be_nil

      # getting_confirmed_elsewhere is removed
      getting_confirmed_elsewhere = Candidate.find_by(account_name: 'Getting_Confirmed_elsewhere_cand_year2')
      expect(getting_confirmed_elsewhere).to be_nil
      expect_table_rows(Candidate, { Address: 3, # 2 for seed + 1 for visitor
                                     BaptismalCertificate: 1,
                                     Candidate: 1,
                                     CandidateEvent: 2,
                                     CandidateSheet: 1,
                                     ChristianMinistry: 1,
                                     ConfirmationEvent: 2,
                                     PickConfirmationName: 1,
                                     RetreatVerification: 1,
                                     SponsorCovenant: 1,
                                     SponsorEligibility: 1,
                                     ScannedImage: 0,
                                     ToDo: 2 })
    end

    it 'start a new year will remove candidates with status of From another parish.' do
      from_another_parish = FactoryBot.create(:candidate, account_name: 'Getting_Confirmed_elsewhere')
      from_another_parish.candidate_sheet.program_year = 2
      from_another_parish.status_id = Status.from_another_parish.id
      from_another_parish.save
      expect(Candidate.count).to eq(1)

      ResetDB.start_new_year

      vicki_candidate = Candidate.find_by(account_name: 'vickikristoff')
      expect(vicki_candidate).not_to be_nil

      # getting_confirmed_elsewhere is removed
      from_another_parish = Candidate.find_by(account_name: 'Getting_Confirmed_elsewhere')
      expect(from_another_parish).to be_nil
      expect_table_rows(Candidate, { Address: 3, # 2 for seed + 1 for visitor
                                     BaptismalCertificate: 1,
                                     Candidate: 1,
                                     CandidateEvent: 2,
                                     CandidateSheet: 1,
                                     ChristianMinistry: 1,
                                     ConfirmationEvent: 2,
                                     PickConfirmationName: 1,
                                     RetreatVerification: 1,
                                     SponsorCovenant: 1,
                                     SponsorEligibility: 1,
                                     ScannedImage: 0,
                                     ToDo: 2 })
    end

    describe 'reset system back to original state' do
      it 'reset after adding in some candidates' do
        expect(Candidate.all.size).to eq(0)
        FactoryBot.create(:candidate, account_name: 'a1')
        FactoryBot.create(:candidate, account_name: 'a2')
        FactoryBot.create(:candidate, account_name: 'a3')
        expect(Candidate.all.size).to eq(3)

        expect(Admin.all.size).to eq(0)
        FactoryBot.create(:admin, account_name: 'AdminV', email: 'paul@kristoffs.com', name: 'Paul')
        FactoryBot.create(:admin, account_name: 'AdminP', email: 'vicki@kristoffs.com', name: 'Vicki')
        expect(Admin.count).to eq(2)

        ResetDB.reset_database

        expect(Candidate.count).to eq(1)
        expect(Candidate.find_by(account_name: 'vickikristoff')).not_to be_nil
        expect(Admin.count).to eq(1)
        expect(Admin.find_by(email: Admin.first.email)).not_to be_nil
        expect(Status.count).to be(4)
      end
    end
  end

  private

  def create_scanned_image
    content = ''
    File.open(File.join('spec/fixtures/files/actions.png'), 'rb') do |f|
      content = f.read
    end
    ScannedImage.new(
      filename: 'actions.png',
      content_type: 'image/png',
      content: content
    )
  end

  def expect_table_rows(clazz, expected_sizes, checked = [], do_not_include = [Admin])
    top = checked == []
    class_sym = clazz.to_s.to_sym
    unless checked.include?(class_sym) || do_not_include.include?(clazz)
      checked << class_sym
      expected = "Association(#{clazz}) size #{clazz.count} does mot match expected size #{expected_sizes[class_sym]}"
      expect(expected_sizes[class_sym]).to eq(clazz.count), expected
      clazz.reflect_on_all_associations.each do |assoc_reflect|
        assoc_class = assoc_reflect.klass
        expect_table_rows(assoc_class, expected_sizes, checked, do_not_include)
      end
    end
    return unless top

    unless checked.size == expected_sizes.size
      puts checked
      puts expected_sizes
    end
    expect(checked.size).to eq(expected_sizes.size)
  end

  def expect_cand_values(cand, values)
    expect(Status.active?(cand.status_id)).to be(true)
    expect(cand.candidate_sheet.program_year).to eq(values[:program_year])
    expect(cand.candidate_sheet.grade).to eq(values[:grade])
  end
end
