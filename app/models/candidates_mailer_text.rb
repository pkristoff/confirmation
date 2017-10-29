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

  def initialize(parms)
    @candidate = parms[:candidate]
    @subject = parms[:subject]
    @body_text = parms[:body_input]
    if @body_text.is_a? Hash
      @pre_late_text = @body_text[:pre_late_text]
      @pre_coming_due_text = @body_text[:pre_coming_due_text]
      @completed_awaiting_text = @body_text[:completed_awaiting_text]
      @completed_text = @body_text[:completed_text]
      @closing_text = @body_text[:closing_text]
      @salutation_text = @body_text[:salutation_text]
      @from_text = @body_text[:from_text]
    end
  end

  def late_events
    candidate.get_late_events
  end

  def coming_due_events
    candidate.get_coming_due_events
  end

  def awaiting_candidate_events
    candidate.get_awaiting_candidate_events
  end

  def completed_awaiting_events
    candidate.get_awaiting_admin_events
  end

  def completed_events
    candidate.get_completed
  end

end