class Address < ActiveRecord::Base

  # validates_presence_of :street_1, :city, :state, :zip_code

  def self.get_basic_permitted_params
    [:street_1, :street_2, :city, :state, :zip_code, :id]
  end

  def self.get_basic_validatiion_params
    params = Address.get_basic_permitted_params
    params.delete(:street_2)
    params
  end

  # event_complete

  def validate_event_complete(options={})
    EventCompleteValidator.new(self).validate(Address.get_basic_validatiion_params)
  end

  # event_complete - end

end
