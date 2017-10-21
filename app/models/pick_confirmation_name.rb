class PickConfirmationName < ActiveRecord::Base

  # event_complete

  def validate_event_complete(options={})
    EventCompleteValidator.new(self).validate(PickConfirmationName.get_permitted_params)
  end

  def self.get_permitted_params
    [:saint_name, :id]
  end

  def self.event_name
    I18n.t('events.confirmation_name')
  end

  def self.validate_event_complete(candidate)
    pick_confirmation_name = candidate.pick_confirmation_name
    pick_confirmation_name.validate_event_complete
    pick_confirmation_name
  end

  # event_complete - end

  def verifiable_info(candidate)
    {'Confirmation name': saint_name
    }
  end

end