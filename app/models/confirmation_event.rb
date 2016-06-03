class ConfirmationEvent < ActiveRecord::Base

  has_many :to_dos
  has_many :candidate_events, through: :to_dos
end
