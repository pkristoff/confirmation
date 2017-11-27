class CandidateEvent < ActiveRecord::Base
  # http://guides.rubyonrails.org/association_basics.html#the-has-and-belongs-to-many-association
  # has_and_belongs_to_many :confirmation_event
  # accepts_nested_attributes_for :confirmation_event, allow_destroy: false

  has_one :to_do, dependent: :destroy
  has_one :confirmation_event, through: :to_do
  accepts_nested_attributes_for :confirmation_event, allow_destroy: false
  belongs_to(:candidate)

  def due_date
    if self.candidate.candidate_sheet.attending === 'The Way'
      confirmation_event.the_way_due_date
    else
      confirmation_event.chs_due_date
    end
  end

  def instructions
    confirmation_event.instructions
  end

  def name
    confirmation_event.name
  end

  #status

  def started?
    CandidateEvent.started?(due_date)
  end

  def self.started?(due_date)
    !due_date.nil?
  end

  def awaiting_candidate?
    CandidateEvent.awaiting_candidate?(due_date, completed_date)
  end

  def self.awaiting_candidate?(due_date, completed_date)
    CandidateEvent.started?(due_date) and completed_date.nil?
  end

  def awaiting_admin?
    CandidateEvent.awaiting_admin?(due_date, completed_date, verified)
  end

  def self.awaiting_admin?(due_date, completed_date, verified)
    CandidateEvent.started?(due_date) and !completed_date.nil? and !verified
  end

  def coming_due?
    CandidateEvent.coming_due?(due_date, completed_date)
  end

  def self.coming_due?(due_date, completed_date)
    today = Date.today
    CandidateEvent.awaiting_candidate?(due_date, completed_date) and (due_date >= today) and (due_date < today+30)
  end

  def completed?
    CandidateEvent.completed?(due_date, verified)
  end

  def self.completed?(due_date, verified)
    CandidateEvent.started?(due_date) and verified
  end

  def late?
    CandidateEvent.late?(due_date, completed_date)
  end

  def self.late?(due_date, completed_date)
    CandidateEvent.awaiting_candidate?(due_date, completed_date) and (due_date < Date.today)
  end

  def self.status(due_date, completed_date,verified)
    return I18n.t('status.not_started') unless self.started?(due_date)
    return I18n.t('status.coming_due') if self.coming_due?(due_date, completed_date)
    return I18n.t('status.late') if self.late?(due_date, completed_date)
    return I18n.t('status.awaiting_candidate') if self.awaiting_candidate?(due_date, completed_date)
    return I18n.t('status.awaiting_admin') if self.awaiting_admin?(due_date, completed_date, verified)
    return I18n.t('status.verified') if self.completed?(due_date, verified)
    raise("Unknown candidate_event status")
  end

  def status
    CandidateEvent.status(due_date, completed_date, verified)
  end

  # end status

  def self.get_permitted_params
    [:id, :completed_date, :verified,
     confirmation_event_attributes: ConfirmationEvent.get_permitted_params]
  end

  def verifiable_info
    candidate.get_event_association(route).verifiable_info(candidate)
  end

  def route
    # TODO: maybe move to constants
    case name
      when I18n.t('events.baptismal_certificate')
        :baptismal_certificate
      when I18n.t('events.candidate_covenant_agreement')
        :candidate_covenant_agreement
      when I18n.t('events.candidate_information_sheet')
        :candidate_information_sheet
      when I18n.t('events.christian_ministry')
        :christian_ministry
      when I18n.t('events.confirmation_name')
        :confirmation_name
      when I18n.t('events.parent_meeting')
        :parent_meeting
      when I18n.t('events.sponsor_agreement')
        :sponsor_agreement
      when I18n.t('events.sponsor_covenant')
        :sponsor_covenant
      when I18n.t('events.retreat_verification')
        :retreat_verification
      else
        raise "Unknown event to route: #{name}"
    end
  end

  def mark_completed(validated, cand_assoc_class)
    if validated
      if self.completed_date.nil?
        self.completed_date = Date.today
        # automatically mark verified when completed.
        self.verified = ['CandidateSheet', 'ChristianMinistry'].include?(cand_assoc_class.to_s)
      end
    else
      unless self.completed_date.nil?
        self.completed_date = nil
        self.verified = false
      end
    end
  end

end
