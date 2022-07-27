# frozen_string_literal: true

# holder of visitor page info.
#
class Visitor < ApplicationRecord
  before_create :confirm_singularity

  belongs_to(:home_parish_address, class_name: 'Address', validate: true, dependent: :destroy)
  accepts_nested_attributes_for :home_parish_address, allow_destroy: true

  after_initialize :build_associations, if: :new_record?

  # Editable attributes
  #
  # === Returns:
  #
  # * <tt>Array</tt> of attributes
  #
  def self.basic_permitted_params
    %i[id home about contact home_parish]
  end

  # Editable attributes
  #
  # === Returns:
  #
  # * <tt>Array</tt> of attributes
  #
  def self.permitted_params
    Visitor.basic_permitted_params.concat(
      [{ home_parish_address_attributes: Address.basic_permitted_params }]
    )
  end

  # The home parish of the current Visitor
  #
  def self.home_parish
    Visitor.visitor.home_parish
  end

  # Returns Visitor
  #
  # === Returns:
  #
  # * <tt>Visitor</tt>
  #
  def self.visitor
    raise 'No Visitor' if Visitor.count.zero?

    raise 'More than one Visitor' if Visitor.count > 1

    Visitor.all.first
  end

  private

  def build_associations
    home_parish_address || build_home_parish_address
  end

  def confirm_singularity
    raise StandardError, 'There can be only one.' if Visitor.count.positive?
  end
end
