class CandidateEvent < ActiveRecord::Base
  # http://guides.rubyonrails.org/association_basics.html#the-has-and-belongs-to-many-association
  # has_and_belongs_to_many :confirmation_event
  # accepts_nested_attributes_for :confirmation_event, allow_destroy: false

  has_one :to_do
  has_one :confirmation_event, through: :to_do
  accepts_nested_attributes_for :confirmation_event, allow_destroy: false
  belongs_to(:candidate)

  def due_date
    confirmation_event.due_date
  end

  def name
    confirmation_event.name
  end

  def started?
    ! due_date.nil?
  end

  def awaiting_candidate?
    started? and completed_date.nil?
  end

  def completed?
    started? and admin_confirmed
  end

  def late?
    started? and awaiting_candidate? and (due_date < Date.today)
  end

end
