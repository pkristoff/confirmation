class EventCompleteValidator
  def initialize(association, validate_others=false)
    @association = association
    @validate_others = validate_others
  end

  def validate(attributes, other_attributes=[])
    @association.validates_presence_of attributes unless attributes.empty?
    @association.validates_presence_of other_attributes if @validate_others
  end

  # if either set passes for having all its attributes present then everything is OK
  def validate_either(attributes, other_attributes)
    @association.validates_presence_of attributes
    if @association.errors.any?
      # if we find errors the try the other_attributes
      @association.errors.clear
      @association.validates_presence_of other_attributes
      if @association.errors.any?
        # if find errors in other_attributes then add the attribute errors back in.
        @association.validates_presence_of attributes
      end
    end
  end

  def sub_validate(sub_association, attributes)
    if @validate_others
      sub_association.validates_presence_of attributes
      sub_association.errors.full_messages.each do |msg|
        @association.errors[:base] << msg
      end
    end
  end
end