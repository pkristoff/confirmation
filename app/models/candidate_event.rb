class CandidateEvent < ActiveRecord::Base
  # http://guides.rubyonrails.org/association_basics.html#the-has-and-belongs-to-many-association
  # has_and_belongs_to_many :confirmation_event
  # accepts_nested_attributes_for :confirmation_event, allow_destroy: false

  has_one :to_do
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

  def started?
    !due_date.nil?
  end

  def awaiting_candidate?
    started? and completed_date.nil?
  end

  def awaiting_admin?
    started? and !completed_date.nil? and !verified?
  end

  def coming_due?
    started? and completed_date.nil? and (due_date >= Date.today)
  end

  def completed?
    started? and verified
  end

  def late?
    started? and awaiting_candidate? and (due_date < Date.today)
  end

  def self.get_permitted_params
    [:id, :completed_date, :verified,
    confirmation_event_attributes: ConfirmationEvent.get_permitted_params]
  end

  def verifiable_info
    candidate.get_event_association(route).verifiable_info
  end

  def status
    return 'Not Started' unless started?
    return 'Awaiting Candidate' if awaiting_candidate?
    return 'Awaiting Admin' if awaiting_admin?
    return 'Coming Due' if coming_due?
    return 'Completed' if completed?
    return 'Late' if late?
    'Unknown Status'
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
      when I18n.t('events.retreat_weekend')
        :retreat_weekend
      when I18n.t('events.sponsor_agreement')
        :sponsor_agreement
      when I18n.t('events.sponsor_covenant')
        :sponsor_covenant
      else
        raise "Unknown event to route: #{name}"
    end
  end

end
