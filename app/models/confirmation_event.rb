class ConfirmationEvent < ActiveRecord::Base

  has_many :to_dos
  has_many :candidate_events, through: :to_dos
  before_save :scrub_instructions

  private

  def scrub_instructions()
    # the UI should do this but it always good make sure here.
    self.instructions= Loofah.fragment(self.instructions).scrub!(:prune).scrub!(:whitewash)
    true
  end
end
