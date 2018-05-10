# frozen_string_literal: true

#
# Used to hold information input from client
#
class CandidatesMailerText
  attr_accessor :candidate

  attr_accessor :subject
  attr_accessor :body_text
  attr_accessor :pre_late_text
  attr_accessor :pre_coming_due_text
  attr_accessor :completed_awaiting_text
  attr_accessor :completed_text
  attr_accessor :closing_text
  attr_accessor :salutation_text
  attr_accessor :from_text
  attr_accessor :token

  # Instantiation
  #
  # === Parameters:
  #
  # * <tt>:parms</tt>
  #
  def initialize(parms)
    @candidate = parms[:candidate]
    @subject = parms[:subject]
    @body_text = parms[:body_input]

    return unless @body_text.is_a? Hash

    @pre_late_text = @body_text[:pre_late_text]
    @pre_coming_due_text = @body_text[:pre_coming_due_text]
    @completed_awaiting_text = @body_text[:completed_awaiting_text]
    @completed_text = @body_text[:completed_text]
    @closing_text = @body_text[:closing_text]
    @salutation_text = @body_text[:salutation_text]
    @from_text = @body_text[:from_text]
  end

  # late CandidateEvent
  #
  # === Return:
  #
  # Array: CandidateEvent
  #
  delegate :late_events, to: :candidate

  # coming due (due within 30 days) CandidateEvent
  #
  # === Return:
  #
  # Array: CandidateEvent
  #
  delegate :coming_due_events, to: :candidate

  # awaiting candidate CandidateEvent
  #
  # === Return:
  #
  # Array: CandidateEvent
  #
  delegate :awaiting_candidate_events, to: :candidate

  # awaiting admin verification CandidateEvent
  #
  # === Return:
  #
  # Array: CandidateEvent
  #
  def completed_awaiting_events
    candidate.awaiting_admin_events
  end

  # completed CandidateEvent
  #
  # === Return:
  #
  # Array: CandidateEvent
  #
  def completed_events
    candidate.completed
  end
end
