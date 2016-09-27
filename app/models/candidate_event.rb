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
    {a: 'a',
    e: 'e',
    b: 'b'}
  end

end
