class EventCompleteValidator
  def initialize(association, validate_others=false)
    @association = association
    @validate_others = validate_others
  end

  def validate(attributes, other_attributes=[])
    @association.validates_presence_of attributes unless attributes.empty?
    @association.validates_presence_of other_attributes if @validate_others
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