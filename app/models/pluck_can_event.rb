# frozen_string_literal: true

# PluckCanEvent
#
class PluckCanEvent
  attr_accessor :candidate_id,
                :confirmation_event_id,
                :candidate_event_id,
                :event_key,
                :verified,
                :completed_date,
                :program_year1_due_date,
                :program_year2_due_date

  # returns a PluckCanEvent from plucked CandidateEvent and corresponding
  # ConfirmationEvent
  #
  # === Parameters:
  #
  # * <tt>:event_info</tt> plucked CandidateEvent
  #
  def initialize(event_info)
    @candidate_id = event_info[0]
    @confirmation_event_id = event_info[1]
    @candidate_event_id = event_info[2]
    @event_key = event_info[3]
    @verified = event_info[4]
    @completed_date = event_info[5]
    @program_year1_due_date = event_info[6]
    @program_year2_due_date = event_info[7]
  end

  # Gather candidate_events information
  #
  # === Returns:
  #
  # * <tt>Array</tt> of candidate_event information
  #
  def self.pluck_awaiting_admin_cand_events
    cand_event_info = {}
    ToDo.joins(:confirmation_event, :candidate_event)
        .where(confirmation_event: { event_key: BaptismalCertificate.event_key })
        .where(candidate_event: { verified: false })
        .where.not(confirmation_event: { program_year2_due_date: nil })
        .where.not(candidate_event: { completed_date: nil })
        .pluck(:candidate_id,
               :confirmation_event_id,
               :candidate_event_id,
               :event_key,
               :verified,
               :completed_date,
               :program_year1_due_date,
               :program_year2_due_date).each do |info|
      pluck_cand_event = PluckCanEvent.new(info)
      cand_info = cand_event_info[pluck_cand_event.candidate_id]
      if cand_info.nil?
        cand_info = []
        cand_event_info[pluck_cand_event.candidate_id] = cand_info
      end
      cand_info << pluck_cand_event
    end
    cand_event_info
  end

  # generate info for showing candidates
  #
  def self.pluck_cand_events
    cand_event_info = {}
    ToDo.joins(:confirmation_event, :candidate_event).pluck(:candidate_id,
                                                            :confirmation_event_id,
                                                            :candidate_event_id,
                                                            :event_key,
                                                            :verified,
                                                            :completed_date,
                                                            :program_year1_due_date,
                                                            :program_year2_due_date).each do |info|
      pluck_cand_event = PluckCanEvent.new(info)
      cand_info = cand_event_info[pluck_cand_event.candidate_id]
      if cand_info.nil?
        cand_info = []
        cand_event_info[pluck_cand_event.candidate_id] = cand_info
      end
      cand_info << pluck_cand_event
    end
    cand_event_info
  end
end
