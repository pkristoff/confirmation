# frozen_string_literal: true

# PluckBapCandidate
#
class PluckBapCandidate
  attr_accessor :id, :first_name, :middle_name, :last_name, :baptismal_certificate_id, :plucked_can_events, :event

  # returns a PluckBapCandidate from plucked baptismal CandidateEvent and corresponding
  # ConfirmationEvent
  #
  # === Parameters:
  #
  # * <tt>:cand_info</tt> plucked candidate info
  # * <tt>:plucked_candidate_events</tt> plucked baptismal CandidateEvent
  #
  def initialize(cand_info, plucked_candidate_events)
    @id = cand_info[0]
    @first_name = cand_info[1]
    @middle_name = cand_info[2]
    @last_name = cand_info[3]
    @baptismal_certificate_id = cand_info[4]
    @plucked_can_events = plucked_candidate_events
  end

  # used for sorting
  #
  # === Parameters:
  #
  # * <tt>:other</tt> another PluckBapCandidate
  #
  # === Returns:
  #
  # * <tt>Integer</tt> -1, 0, or 1
  #
  def <=>(other)
    ans = last_name <=> other.last_name
    return first_name <=> other.first_name if ans.zero?

    ans
  end

  # Returns Date the candidate event has been completed
  #
  # === Returns:
  #
  # * <tt>Date</tt>
  #
  delegate :completed_date, to: :event

  # Gather baptismal certificate info
  #
  # === Returns:
  #
  # * <tt>Array</tt> of baptismal certificate information
  #
  def self.pluck_bap_candidates
    awaiting_admin_cand_events = PluckCanEvent.pluck_awaiting_admin_cand_events
    baptist_candidates = awaiting_admin_cand_events.map do |awaiting_admin_cand_event|
      pluck_bap_candidate = nil
      candidate_id = awaiting_admin_cand_event[0]
      pluck_can_event = awaiting_admin_cand_event[1]
      join = Candidate.joins(:candidate_sheet).where(id: candidate_id)
      join.pluck(:id, :first_name, :middle_name, :last_name, :baptismal_certificate_id).each do |cand_info|
        pluck_bap_candidate = PluckBapCandidate.new(cand_info, pluck_can_event)
      end
      pluck_bap_candidate
    end
    baptist_candidates.sort!
    baptist_candidates
  end
end
