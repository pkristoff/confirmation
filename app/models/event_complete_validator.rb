# frozen_string_literal: true

#
# Event Complete Validator Helper
#
class EventCompleteValidator
  # Instantiation
  #
  # === Parameters:
  #
  # * <tt>:association</tt>
  # * <tt>:validate_others</tt>
  #
  def initialize(association, validate_others: false)
    @association = association
    @validate_others = validate_others
  end

  # Calcuate status of candidate_event
  #
  # === Parameters:
  #
  # * <tt>:attributes</tt>
  # * <tt>:other_attributes</tt>
  #
  def validate(attributes, other_attributes = [])
    @association.validates_presence_of attributes unless attributes.empty?
    @association.validates_presence_of other_attributes if @validate_others
  end

  # if either set passes for having all its attributes present then everything is OK
  #
  # === Parameters:
  #
  # * <tt>:attributes</tt>
  # * <tt>:other_attributes</tt>
  #
  def validate_either(attributes, other_attributes)
    @association.validates_presence_of attributes
    return unless @association.errors.any?

    # if we find errors the try the other_attributes
    @association.errors.clear
    @association.validates_presence_of other_attributes
    return unless @association.errors.any?

    # if find errors in other_attributes then add the attribute errors back in.
    @association.validates_presence_of attributes
  end

  # Validate association of association
  #
  # === Parameters:
  #
  # * <tt>:sub_association</tt>
  # * <tt>:attributes</tt>
  #
  def sub_validate(sub_association, attributes)
    return unless @validate_others

    sub_association.validates_presence_of attributes
    sub_association.errors.full_messages.each do |msg|
      @association.errors[:base] << msg
    end
  end
end
