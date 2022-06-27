# frozen_string_literal: true

# A place for common model info
#
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # This assumes child_association has been validated and
  # moves the errors messages from child association to self errors
  #
  # === Parameters:
  #
  # * <tt>:child_association</tt>
  # * <tt>:event_complete</tt>
  #
  # === Returns:
  #
  # * <tt>Boolean</tt> - returns whether child_association is complete.
  #
  def propagate_errors_up(child_association, event_complete)
    child_association.errors.full_messages.each do |msg|
      errors.add(:base, msg)
      event_complete = false
    end
    event_complete
  end

  # Renames scanned image error message
  #
  # === Parameters:
  #
  # * <tt>:image_name</tt> a symbol
  # * <tt>:new_message</tt>
  #
  def rename_scanned_image_error_message(image_name, new_message)
    found = false
    found |= !errors.delete(image_name).nil?
    errors.add(:base, new_message) if found
  end
end
