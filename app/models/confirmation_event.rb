# frozen_string_literal: true

#
# A common event that all candidates have to do in order to be confirmed.
#
class ConfirmationEvent < ApplicationRecord
  # added dependent to handle Rails/HasManyOrHasOneDependent, but does not
  # seem to have an affect.
  has_many :to_dos, dependent: :destroy
  has_many :candidate_events, through: :to_dos, dependent: :destroy
  before_save :scrub_instructions

  # TODO: valid presence of

  # Editable attributes
  #
  # === Returns:
  #
  # Array of attributes
  #
  def self.permitted_params
    %i[id name the_way_due_date instructions chs_due_date]
  end

  private

  # Make sure a hacker has not tried to do something not permitted.
  #
  def scrub_instructions
    # the UI should do this but it always good make sure here.
    # depending on migration this may not have instructions

    self.instructions = Loofah.fragment(instructions).scrub!(:prune).scrub!(:whitewash) if respond_to?(:instructions)

    true
  end
end
