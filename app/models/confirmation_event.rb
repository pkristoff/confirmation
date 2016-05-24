class ConfirmationEvent < ActiveRecord::Base

  has_many :confirmation_event_candidate_event
  has_many :candidate_events, through: :confirmation_event_candidate_event
end
