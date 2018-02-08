# frozen_string_literal: true

#
# Used to conect CandaditeEvent to ConfirmationEvent
#
class ToDo < ActiveRecord::Base
  belongs_to :candidate_event
  belongs_to :confirmation_event
end
