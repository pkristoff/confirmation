# frozen_string_literal: true

# holder of visitor page info.
#
class Visitor < ApplicationRecord

  before_create :confirm_singularity

  # Editable attributes
  #
  # === Returns:
  #
  # * <tt>Array</tt> of attributes
  #
  def self.basic_permitted_params
    %i[home about contact]
  end

  private

  def confirm_singularity
    raise Exception.new("There can be only one.") if Visitor.count > 0
  end
end
