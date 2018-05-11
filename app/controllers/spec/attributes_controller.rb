# frozen_string_literal: true

# A fixture used by rubocop extensions to test
# uniformity of documentation
#
class AttributesController < ActionController
  # Legal use of attributes
  #
  # === Attributes:
  #
  # * <tt>:id</tt> Candidate id
  #
  def legal_attributes
    uuu(params[:id])
  end

  # Missing blank comment first
  #
  # === Attributes:
  # * <tt>:id</tt> Candidate id
  #
  def missing_blank_comment_attributes_first
    uuu(params[:id])
  end

  # Missing blank comment
  #
  # === Attributes:
  #
  # * <tt>:id</tt> Candidate id
  def missing_blank_comment_attributes_last
    uuu(params[:id])
  end

  # Attributes and Parameters should not exist on same method
  #
  # === Attributes:
  #
  # * <tt>:id</tt> Candidate id
  #
  # === Parameters:
  #
  # * <tt>:arg1</tt> First Parameter
  #
  def attributes_parameters_no_coexisting(arg1)
    uuu(params[:id], arg1)
  end

  # Attributes should be before Returns
  #
  # === Returns:
  #
  # ** <code>:Boolean</code>
  #
  # === Attributes:
  #
  # * <tt>:id</tt> Candidate id
  #
  def attributes_should_be_before_returns
    uuu(params[:id])
    true
  end

  # === Attributes:
  #
  # * <tt>:id</tt> Candidate id
  #
  # Attributes should be before Description
  #
  def attributes_should_be_before_description
    uuu(params[:id])
    true
  end
end