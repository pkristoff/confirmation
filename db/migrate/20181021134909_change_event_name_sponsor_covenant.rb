class ChangeEventNameSponsorCovenant < ActiveRecord::Migration[5.2]
  OLD_VALUE = 'Sponsor Covenant'

  def self.up
    ce = ConfirmationEvent.find_by(name: OLD_VALUE)
    new_value = SponsorCovenant.event_name
    ce.name = new_value if ce
    ce.save if ce
    raise(RuntimeError, "Confirmation Event not found: #{OLD_VALUE} (old value)") unless ce
  end
  def self.down
    new_value = SponsorCovenant.event_name
    ce = ConfirmationEvent.find_by(name: new_value)
    ce.name = OLD_VALUE if ce
    ce.save if ce
    raise(RuntimeError, "Confirmation Event not found: #{new_value} (new value)") unless ce
  end
end
