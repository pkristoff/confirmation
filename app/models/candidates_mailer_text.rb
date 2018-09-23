# frozen_string_literal: true

#
# Used to hold information input from client
#
class CandidatesMailerText
  attr_accessor :candidate

  attr_accessor :subject
  attr_accessor :body_text
  attr_accessor :pre_late_input
  attr_accessor :pre_coming_due_input
  attr_accessor :completed_awaiting_input
  attr_accessor :completed_input
  attr_accessor :closing_input
  attr_accessor :salutation_input
  attr_accessor :from_input
  attr_accessor :token

  # Instantiation
  #
  # === Parameters:
  #
  # * <tt>:parms</tt>
  #
  def initialize(parms)
    @candidate = parms[:candidate]
    @subject = parms[:subject].text
    @body_text = parms[:body_text]

    @body_text = @body_text.text unless @body_text.is_a? Hash
    return unless @body_text.is_a? Hash

    @pre_late_input = @body_text[:pre_late_input].text
    @pre_coming_due_input = @body_text[:pre_coming_due_input].text
    @completed_awaiting_input = @body_text[:completed_awaiting_input].text
    @completed_input = @body_text[:completed_input].text
    @closing_input = @body_text[:closing_input].text
    @salutation_input = @body_text[:salutation_input].text
    @from_input = @body_text[:from_input].text
  end

  # late CandidateEvent
  #
  # === Returns:
  #
  # * <tt>Array</tt> CandidateEvent
  #
  delegate :late_events, to: :candidate

  # coming due (due within 30 days) CandidateEvent
  #
  # === Returns:
  #
  # * <tt>Array</tt> CandidateEvent
  #
  delegate :coming_due_events, to: :candidate

  # awaiting candidate CandidateEvent
  #
  # === Returns:
  #
  # * <tt>Array</tt> CandidateEvent
  #
  delegate :awaiting_candidate_events, to: :candidate

  # awaiting admin verification CandidateEvent
  #
  # === Returns:
  #
  # * <tt>Array</tt> CandidateEvent
  #
  def completed_awaiting_events
    candidate.awaiting_admin_events
  end

  # completed CandidateEvent
  #
  # === Returns:
  #
  # * <tt>Array</tt> CandidateEvent
  #
  def completed_events
    candidate.completed
  end
end
