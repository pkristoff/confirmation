# frozen_string_literal: true

describe ResetDB, type: :model do
  describe 'start new year' do
    it 'should start a new year will clean out candidates and all its associations' do
      FactoryBot.create(:admin, email: 'paul@kristoffs.com', name: 'Paul')
      AppFactory.add_confirmation_events

      expect(Admin.all.size).to eq(1)

      cand_assoc = { Address: 0,
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
                     ToDo: 0 }

      expect_table_rows(Candidate, cand_assoc)

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

      cand_assoc = { Address: 9,
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
                     ToDo: 27 }

      expect_table_rows(Candidate, cand_assoc)

      ResetDB.start_new_year

      expect(Admin.all.size).to eq(1)

      cand_assoc = { Address: 3,
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
                     ToDo: 9 }

      expect_table_rows(Candidate, cand_assoc)
    end

    it 'start a new year will clean up dangling references the DB' do
      FactoryBot.create(:admin, email: 'paul@kristoffs.com', name: 'Paul')
      AppFactory.add_confirmation_events

      expect(Admin.all.size).to eq(1)

      cand_assoc = { Address: 0,
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
                     ToDo: 0 }

      expect_table_rows(Candidate, cand_assoc)

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

      expect(Admin.all.size).to eq(1)
      expect(ConfirmationEvent.all.size).to eq(9)
      expect(Candidate.all.size).to eq(3)

      cand_assoc = { Address: 13,
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
                     ToDo: 28 }

      expect_table_rows(Candidate, cand_assoc)

      reset_db.start_new_year

      expect(Admin.all.size).to eq(1)
      expect(ConfirmationEvent.all.size).to eq(9)
      expect(Candidate.all.size).to eq(1) # vickikristoff the seed

      cand_assoc = { Address: 3,
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
                     ToDo: 9 }

      expect_table_rows(Candidate, cand_assoc)
    end
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
      expect(Admin.all.size).to eq(2)

      ResetDB.reset_database

      expect(Candidate.all.size).to eq(1)
      expect(Candidate.find_by(account_name: 'vickikristoff')).not_to eq(nil)
      expect(Admin.all.size).to eq(1)
      expect(Admin.find_by(email: Admin.first.email)).not_to eq(nil)
    end
  end
end

private

def create_scanned_image
  content = ''
  File.open(File.join('spec/fixtures/actions.png'), 'rb') do |f|
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
    expected = "Association(#{clazz}) size #{clazz.all.size} does mot match expected size #{expected_sizes[class_sym]}"
    expect(clazz.all.size).to eq(expected_sizes[class_sym]), expected
    clazz.reflect_on_all_associations.each do |assoc_reflect|
      assoc_class = assoc_reflect.klass
      expect_table_rows(assoc_class, expected_sizes, checked)
    end
  end
  return unless top

  unless checked.size == expected_sizes.size
    puts checked
    puts expected_sizes
  end
  expect(checked.size).to eq(expected_sizes.size)
end
