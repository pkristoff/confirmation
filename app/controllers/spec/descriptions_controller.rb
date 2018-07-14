# frozen_string_literal: true

# A fixture used by rubocop extensions to test
# uniformity of documentation
#
class DescriptionsController < ApplicationController
  # Should not generate any offenses
  #
  def legal_no_args
    uuu
  end

  #
  # Description should not begin with an blank comment ***ERROR
  #
  def description_begins_with_empty_comment
    uuu
  end

  # Description should end with a blank comment ***ERROR
  def description_does_not_end_with_empty_comment
    uuu
  end

  # Should not generate any offenses
  #
  # === Parameters:
  #
  # * <tt>:arg1</tt> First Parameter
  #
  def legal_descriptions(arg1)
    uuu(arg1)
  end

  # === Parameters:
  #
  # * <tt>:arg1</tt> First Parameter
  #
  # Description should be first ***ERROR
  #
  def missing_descriptions(arg1)
    uuu(arg1)
  end

  # Should not generate any offenses
  #
  # === Returns:
  #
  # * <tt>send_data</tt> for spreadsheet
  #
  def legal_description_with_returns
    uuu
  end

  # === Returns:
  #
  # * <tt>send_data</tt> for spreadsheet
  #
  # Description should be first ***ERROR
  #
  def missing_description_with_returns
    uuu
  end

  # Should not generate any offenses
  #
  # === Parameters:
  #
  # * <tt>:arg1</tt> First Parameter
  #
  # === Returns:
  #
  # * <tt>send_data</tt> for spreadsheet
  #
  def legal_description_with_parameters_and_returns(arg1)
    uuu(arg1)
  end

  # === Parameters:
  #
  # * <tt>:arg1</tt> First Parameter
  #
  # Description should be first ***ERROR
  #
  # === Returns:
  #
  # * <tt>send_data</tt> for spreadsheet
  #
  def description_missing_with_parameters_and_returns(arg1)
    uuu(arg1)
  end

  # === Parameters:
  #
  # * <tt>:arg1</tt> First Parameter
  #
  # === Returns:
  #
  # * <tt>send_data</tt> for spreadsheet
  #
  # Description should be first ***ERROR
  #
  def description_missing_with_parameters_and_returns2(arg1)
    uuu(arg1)
  end

  # === Parameters:
  #
  # * <tt>:arg1</tt> First Parameter
  #
  # Description should be first ***ERROR
  #
  def description_missing_with_parameters(arg1)
    uuu(arg1)
  end
end
