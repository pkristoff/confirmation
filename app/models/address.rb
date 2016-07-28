class Address < ActiveRecord::Base

  validates_presence_of :street_1, :city, :state, :zip_code

end
