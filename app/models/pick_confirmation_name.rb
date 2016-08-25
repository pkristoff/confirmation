class PickConfirmationNameValidator < ActiveModel::Validator
  def initialize(pick_confirmation_name)
    @pick_confirmation_name = pick_confirmation_name
  end

  def validate
    @pick_confirmation_name.validates_presence_of [:saint_name, :about_saint, :why_saint, :pick_confirmation_name_filename, :pick_confirmation_name_content_type, :pick_confirmation_name_file_contents]
  end
end

class PickConfirmationName < ActiveRecord::Base

  attr_accessor :pick_confirmation_name_picture

  def validate_self
    PickConfirmationNameValidator.new(self).validate
  end

end