# frozen_string_literal: true

describe Orphaneds, type: :model do
  describe 'orphaned associations errors' do
    it 'login should not cause orphaned associations' do
      FactoryBot.create(:candidate)
      expect_no_orphaned_associations
    end
  end

  describe 'orphaned associations' do
    it 'No orphaned associations' do
      FactoryBot.create(:candidate)
      expect_no_orphaned_associations
    end

    it 'orphaned associations' do
      orphans = expected_orphans
      FactoryBot.create(:candidate)
      orphaneds = Orphaneds.new
      # create orphans
      expect_orphans(orphaneds, orphans)
    end

    it 'destroy orphaned associations' do
      orphans = expected_orphans

      FactoryBot.create(:candidate)
      orphaneds = Orphaneds.new
      orphaneds.add_orphaned_table_rows

      expect_orphans(orphaneds, orphans)

      orphaneds.remove_orphaned_table_rows

      orphaneds = Orphaneds.new.add_orphaned_table_rows
      orphaned_table_rows = orphaneds.orphaned_table_rows
      orphaned_table_rows.each do |key, orphan_ids|
        expect(orphan_ids.size).to be(0), "There should be no orphaned rows for '#{key}': #{orphan_ids}"
      end
    end
  end
end

private

def expect_no_orphaned_associations
  orphaneds = Orphaneds.new
  orphaneds.add_orphaned_table_rows
  orphaned_table_rows = orphaneds.orphaned_table_rows
  orphaned_table_rows.each do |_key, orphan_ids|
    expect(orphan_ids).to be_empty
  end
end

def expected_orphans
  {
    # Candidate associations
    BaptismalCertificate: FactoryBot.create(:baptismal_certificate, skip_address_replacement: true),
    CandidateSheet: FactoryBot.create(:candidate_sheet),
    ChristianMinistry: FactoryBot.create(:christian_ministry),
    PickConfirmationName: FactoryBot.create(:pick_confirmation_name),
    RetreatVerification: FactoryBot.create(:retreat_verification),
    SponsorCovenant: FactoryBot.create(:sponsor_covenant),
    SponsorEligibility: FactoryBot.create(:sponsor_eligibility),
    # # other associations
    ScannedImage: FactoryBot.create(:scanned_image),
    Address: FactoryBot.create(:address),
    ToDo: FactoryBot.create(:to_do, confirmation_event_id: nil, candidate_event_id: nil)
  }
end

def expect_orphans(orphaneds, orphans)
  orphaneds.add_orphaned_table_rows
  orphaned_table_rows = orphaneds.orphaned_table_rows
  orphaned_table_rows.each do |key, orphan_ids|
    expect(orphan_ids.size).to be(1), "There should be only one orphaned row for '#{key}': #{orphan_ids}"
    expect(orphan_ids[0]).to be(orphans[key].id), "Id mismatch for '#{key}' orphan:#{orphan_ids[0]} expected:#{orphans[key].id}"
  end
end
