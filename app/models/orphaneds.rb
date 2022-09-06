# frozen_string_literal: true

#
# A helper class used for orphaned table entries.
#
class Orphaneds
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :orphaned_table_rows, :candidate_missing_associations

  # initialize new instance
  #
  # === Returns:
  #
  # * <tt>Orphaneds</tt> instance
  #
  def initialize
    super

    @orphaned_table_rows = {}
    @candidate_missing_associations = []
  end

  # Returns the image filename
  #
  # === Returns:
  #
  # * <tt>Orphanends</tt> representing image filename
  #
  def self.add_orphaned_table_rows
    Orphaneds.new.add_orphaned_table_rows
  end

  # Returns the image filename
  #
  # === Returns:
  #
  # * <tt>Orphanends</tt> representing image filename
  #
  def self.remove_orphaned_table_rows
    Orphaneds.new.remove_orphaned_table_rows
  end

  # Walks through the associations searching for associations that are created but not associated with parent
  #
  # === Returns:
  #
  # * <tt>CandidateImport</tt> self
  #
  def add_orphaned_table_rows
    begin
      cand_assoc_ids = ids(Candidate)
      add_orphan_entry(:BaptismalCertificate, orphaned_baptismal_certificates(cand_assoc_ids))
      add_orphan_entry(:CandidateSheet, orphaned_candidate_sheets(cand_assoc_ids))
      add_orphan_entry(:ChristianMinistry, orphaned_christian_ministry(cand_assoc_ids))
      add_orphan_entry(:PickConfirmationName, orphaned_pick_name(cand_assoc_ids))
      add_orphan_entry(:RetreatVerification, orphaned_retreat_verification(cand_assoc_ids))
      add_orphan_entry(:SponsorCovenant, orphaned_sponsor_covenant(cand_assoc_ids))
      add_orphan_entry(:SponsorEligibility, orphaned_sponsor_eligibility(cand_assoc_ids))
      add_orphan_entry(:Address, orphaned_addresses)
      add_orphan_entry(:ScannedImage, orphaned_scanned_image)
      add_orphan_entry(:ToDo, orphaned_to_do)
    rescue StandardError => e
      Rails.logger.info 'error while looking for orphans'
      Rails.logger.info e.message
      Rails.logger.info e.backtrace.inspect
      %i[BaptismalCertificate
         CandidateSheet
         ChristianMinistry
         PickConfirmationName
         RetreatVerification
         SponsorCovenant
         SponsorEligibility
         Address
         ScannedImage
         ToDo].each do |key|
        orphaned_table_rows[key] = [:error] unless orphaned_table_rows.nil? || orphaned_table_rows[key]
      end
    end
    self
  end

  # destroy orphaned rows
  #
  # === Returns:
  #
  # * <tt>CandidateImport</tt> self
  #
  def remove_orphaned_table_rows
    cand_ids = ids(Candidate)
    begin
      orphaned_rows = orphaned_baptismal_certificates(cand_ids)
      BaptismalCertificate.destroy(orphaned_rows) unless orphaned_rows.empty?
      orphaned_rows = orphaned_candidate_sheets(cand_ids)
      CandidateSheet.destroy(orphaned_rows) unless orphaned_rows.empty?
      orphaned_rows = orphaned_christian_ministry(cand_ids)
      ChristianMinistry.destroy(orphaned_rows) unless orphaned_rows.empty?
      orphaned_rows = orphaned_pick_name(cand_ids)
      PickConfirmationName.destroy(orphaned_rows) unless orphaned_rows.empty?
      orphaned_rows = orphaned_retreat_verification(cand_ids)
      RetreatVerification.destroy(orphaned_rows) unless orphaned_rows.empty?
      orphaned_rows = orphaned_sponsor_covenant(cand_ids)
      SponsorCovenant.destroy(orphaned_rows) unless orphaned_rows.empty?
      orphaned_rows = orphaned_sponsor_eligibility(cand_ids)
      SponsorEligibility.destroy(orphaned_rows) unless orphaned_rows.empty?
      orphaned_rows = orphaned_addresses
      Address.destroy(orphaned_rows) unless orphaned_rows.empty?
      orphaned_rows = orphaned_scanned_image
      ScannedImage.destroy(orphaned_rows) unless orphaned_rows.empty?
      orphaned_rows = orphaned_to_do
      ToDo.destroy(orphaned_rows) unless orphaned_rows.empty?
    rescue StandardError => e
      Rails.logger.info e.message
      Rails.logger.info "SQL error in #{__method__}"
    end
    @cache = nil
    self
  end

  private

  def add_orphan_entry(key, orphans)
    @orphaned_table_rows[key] = orphans unless orphans.empty?
  end

  # Finds all the Address's that have been orphaned.
  #
  def orphaned_addresses
    class_ids(Address).select do |ar_id|
      church_address = ids(BaptismalCertificate).map { |bc_info| bc_info[1] }
                                                .select { |church_address_id| church_address_id == ar_id }
      prof_address = ids(BaptismalCertificate).map { |bc_info| bc_info[2] }
                                              .select { |prof_church_address_id| prof_church_address_id == ar_id }
      visitor_address = ids(Visitor).map { |visitor_info| visitor_info[1] }.select { |address_id| address_id == ar_id }
      church_address.empty? &&
        prof_address.empty? &&
        visitor_address.empty?
    end
  end

  # Finds all the BaptismalCertificate's that have been orphaned.
  #
  # === Parameters:
  #
  # * <tt>:used_cand_ids</tt> Array:
  #
  # === Returns:
  #
  # * <tt>Array</tt> ids
  #
  def orphaned_baptismal_certificates(used_cand_assoc_ids)
    used_bc_ids = used_cand_assoc_ids.map { |x| x[1] }
    orphaned_ids(BaptismalCertificate, used_bc_ids)
  end

  # Finds all the ChristianMinistry's that have been orphaned.
  #
  # === Parameters:
  #
  # * <tt>:cand_ids</tt> Array:
  #
  # === Returns:
  #
  # * <tt>Array</tt> ids
  #
  def orphaned_christian_ministry(used_cand_assoc_ids)
    used_christian_ministry_ids = used_cand_assoc_ids.map { |x| x[3] }
    orphaned_ids(ChristianMinistry, used_christian_ministry_ids)
  end

  # Finds all the CandidateSheet's that have been orphaned.
  #
  # === Parameters:
  #
  # * <tt>:cand_ids</tt> Array:
  #
  # === Returns:
  #
  # * <tt>Array</tt> ids
  #
  def orphaned_candidate_sheets(used_cand_assoc_ids)
    used_cand_sheet_ids = used_cand_assoc_ids.map { |x| x[2] }
    orphaned_ids(CandidateSheet, used_cand_sheet_ids)
  end

  # Finds all the PickConfirmationName's that have been orphaned.
  #
  # === Parameters:
  #
  # * <tt>:cand_ids</tt> Array:
  #
  # === Returns:
  #
  # * <tt>Array</tt> ids
  #
  def orphaned_pick_name(used_cand_assoc_ids)
    used_pick_name_ids = used_cand_assoc_ids.map { |x| x[4] }
    orphaned_ids(PickConfirmationName, used_pick_name_ids)
  end

  # Finds all the RetreatVerification's that have been orphaned.
  #
  # === Parameters:
  #
  # * <tt>:cand_ids</tt> Array:
  #
  # === Returns:
  #
  # * <tt>Array</tt> ids
  #
  def orphaned_retreat_verification(used_cand_assoc_ids)
    used_retreat_verification_ids = used_cand_assoc_ids.map { |x| x[5] }
    orphaned_ids(RetreatVerification, used_retreat_verification_ids)
  end

  # Finds all the SponsorCovenant's that have been orphaned.
  #
  # === Parameters:
  #
  # * <tt>:cand_ids</tt> Array:
  #
  # === Returns:
  #
  # * <tt>Array</tt> ids
  #
  def orphaned_sponsor_covenant(used_cand_assoc_ids)
    used_sponsor_covenant_ids = used_cand_assoc_ids.map { |x| x[6] }
    orphaned_ids(SponsorCovenant, used_sponsor_covenant_ids)
  end

  # Finds all the SponsorCovenant's that have been orphaned.
  #
  # === Parameters:
  #
  # * <tt>:cand_ids</tt> Array:
  #
  # === Returns:
  #
  # * <tt>Array</tt> ids
  #
  def orphaned_sponsor_eligibility(used_cand_assoc_ids)
    used_sponsor_eligibility_ids = used_cand_assoc_ids.map { |x| x[7] }
    orphaned_ids(SponsorEligibility, used_sponsor_eligibility_ids)
  end

  # Finds all the ScannedImage's that have been orphaned.
  #
  def orphaned_scanned_image
    class_ids(ScannedImage).select do |ar_id|
      ids(BaptismalCertificate).map { |x| x[3] }.select { |scanned_certificate_id| scanned_certificate_id == ar_id }.empty? &&
        ids(BaptismalCertificate).map { |x| x[4] }.select { |scanned_prof_id| scanned_prof_id == ar_id }.empty? &&
        ids(RetreatVerification).map { |x| x[1] }.select { |scanned_retreat_id| scanned_retreat_id == ar_id }.empty? &&
        ids(SponsorCovenant).map { |x| x[1] }.select { |scanned_covenant_id| scanned_covenant_id == ar_id }.empty? &&
        ids(SponsorEligibility).map { |x| x[1] }.select { |scanned_eligibility_id| scanned_eligibility_id == ar_id }.empty?
    end
  end

  # Finds all the ScannedImage's that have been orphaned.
  #
  def orphaned_to_do
    orphaned = ids(ToDo).select do |_todo_id, confirmation_event_id, candidate_event_id|
      class_ids(ConfirmationEvent).select { |ce_id| confirmation_event_id == ce_id }.empty? &&
        class_ids(CandidateEvent).select { |ce_id| candidate_event_id == ce_id }.empty?
    end
    orphaned.map { |id, _ce_id, _cand_id| id }
  end

  # get & cache ids of clazz
  #
  # === Parameters:
  #
  # * <tt>:clazz</tt> Class: class of interest
  #
  # === Returns:
  #
  # * <tt>Array</tt> [...[class_id, assoc_ids...]...]
  #
  def ids(clazz)
    class_sym = clazz.name.to_sym
    @cache = {} if @cache.nil?
    ids = @cache[class_sym]
    return ids unless ids.nil?

    ids = case class_sym
          when :Candidate
            Candidate.pluck(:id, :baptismal_certificate_id, :candidate_sheet_id, :christian_ministry_id,
                            :pick_confirmation_name_id, :retreat_verification_id,
                            :sponsor_covenant_id, :sponsor_eligibility_id)
          when :BaptismalCertificate
            BaptismalCertificate.pluck(:id, :church_address_id, :prof_church_address_id,
                                       :scanned_certificate_id, :scanned_prof_id)
          when :CandidateSheet
            CandidateSheet.pluck(:id).map { |id| [id] }
          when :ChristianMinistry
            ChristianMinistry.pluck(:id).map { |id| [id] }
          when :PickConfirmationName
            PickConfirmationName.pluck(:id).map { |id| [id] }
          when :RetreatVerification
            RetreatVerification.pluck(:id, :scanned_retreat_id)
          when :SponsorCovenant
            SponsorCovenant.pluck(:id, :scanned_covenant_id)
          when :SponsorEligibility
            SponsorEligibility.pluck(:id, :scanned_eligibility_id)
          when :Visitor
            Visitor.pluck(:id, :home_parish_address_id)
          when :ToDo
            ToDo.pluck(:id, :confirmation_event_id, :candidate_event_id)
          when :Address
            Address.pluck(:id).map { |id| [id] }
          when :ScannedImage
            ScannedImage.pluck(:id).map { |id| [id] }
          when :ConfirmationEvent
            # [ConfirmationEvent.pluck(:id)]
            ConfirmationEvent.pluck(:id).map { |id| [id] }
          when :CandidateEvent
            # [CandidateEvent.pluck(:id)]
            CandidateEvent.pluck(:id).map { |id| [id] }
          else
            clazz.pluck(:id)
          end
    @cache[class_sym] = ids
    Rails.logger.info "class_sym=#{class_sym}:  ids=#{ids}"
    ids
  end

  def class_ids(clazz)
    ids(clazz).map { |arr_ids| arr_ids[0] }
  end

  # Orphaned ids for clazz
  #
  # === Parameters:
  #
  # * <tt>:clazz</tt> Class: class of interest
  # * <tt>:used_ids</tt> Array: of ids - ids of clazz used by parent
  # * <tt>:offset</tt>  If present used to offset the ids of clazz (i.e. clazz_id iss an array)
  #
  # === Returns:
  #
  # * <tt>Array</tt> ids
  #
  def orphaned_ids(clazz, used_assoc_ids, offset = nil)
    Rails.logger.info "orphaned_ids-offset=#{offset}:  used_ids=#{used_assoc_ids}" if clazz == ScannedImage
    if offset.nil?
      ans = class_ids(clazz).select { |bc_id| used_assoc_ids.select { |used_id| used_id == bc_id }.empty? }
    else
      ans = class_ids(clazz).select do |clazz_id|
        used_assoc_ids.select do |used_id|
          used_id == clazz_id[offset]
        end.empty?
      end
      ans = ans.map { |x| x[offset] }
    end
    ans
  end
end
