class CandidatesMailerText

  attr_accessor :candidate

  attr_accessor :subject
  attr_accessor :body_text
  attr_accessor :pre_late_text
  attr_accessor :pre_coming_due_text
  attr_accessor :completed_text
  attr_accessor :closing_text
  attr_accessor :salutation_text
  attr_accessor :from_text

  def initialize(parms)
    @candidate = parms[:candidate]
    @subject = parms[:subject]
    @body_text = parms[:body_input]
    @pre_late_text = parms[:pre_late_text]
    @pre_coming_due_text = parms[:pre_coming_due_text]
    @completed_text = parms[:completed_text]
    @closing_text = parms[:closing_text]
    @salutation_text = parms[:salutation_text]
    @from_text = parms[:from_text]
  end

  def late_events
    candidate.get_late_events
  end

  def coming_due_events
    candidate.get_coming_due_events
  end

  def completed_events
    candidate.get_completed
  end

end