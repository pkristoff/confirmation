class ConfirmationEvent < ActiveRecord::Base

  has_many :to_dos
  has_many :candidate_events, through: :to_dos
  before_save :scrub_instructions

  # TODO: valid presence of

  private

  def scrub_instructions()
    # the UI should do this but it always good make sure here.
    # depending on migration this may not have instructions
    if self.respond_to?(:instructions)
      self.instructions= Loofah.fragment(self.instructions).scrub!(:prune).scrub!(:whitewash)
    end
    true
  end
end
