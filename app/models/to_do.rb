# frozen_string_literal: true

#
# Used to conect CandaditeEvent to ConfirmationEvent
#
class ToDo < ApplicationRecord
  belongs_to :candidate_event, dependent: :destroy
  belongs_to :confirmation_event
end
