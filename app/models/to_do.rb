class ToDo < ActiveRecord::Base
  belongs_to :candidate_event
  belongs_to :confirmation_event
end
