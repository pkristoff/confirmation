class CandidateEvent < ActiveRecord::Base
  # http://guides.rubyonrails.org/association_basics.html#the-has-and-belongs-to-many-association
  # has_and_belongs_to_many :confirmation_event
  # accepts_nested_attributes_for :confirmation_event, allow_destroy: false

  has_one :to_do
  has_one :confirmation_event, through: :to_do
  belongs_to(:candidate)

  def due_date
    confirmation_event.due_date
  end

  def name
    confirmation_event.name
  end

end
