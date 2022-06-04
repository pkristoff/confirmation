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
    pluck_candidate_events = PluckCanEvent.pluck_cand_events
    Rails.logger.info("plucked_can_events=#{pluck_candidate_events}")
    join = Candidate.joins(:candidate_sheet)
    sorted = join.order('account_name asc')
    sorted.pluck(:id, :first_name, :middle_name, :last_name, :baptismal_certificate_id).map do |cand_info|
      bap_pluck = PluckBapCandidate.new(cand_info, pluck_candidate_events)
      candidate_id = bap_pluck.id
      event = pluck_candidate_events[candidate_id].find do |cand_event_for_cand|
        cand_event_for_cand.event_key == BaptismalCertificate.event_key
      end
      bap_pluck.event = event
      accept = if bap_pluck.completed_date.nil?
                 false
               else
                 baptismal_certificate = BaptismalCertificate.find_by(id: bap_pluck.baptismal_certificate_id)
                 if baptismal_certificate.baptized_at_home_parish
                   false
                 else
                   true
                 end
               end
      bap_pluck if accept
    end
  end
end
