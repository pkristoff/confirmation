# frozen_string_literal: true

# A fixture used by rubocop extensions to test
# uniformity of documentation
#
class ParametersController < ActionController
  # legal parameters
  #
  # === Parameters:
  #
  # * <tt>:arg1</tt> First Parameter
  #
  # send_data for spreadsheet
  #
  def legal_parameters_syntax(arg1)
    uuu(arg1)
  end

  # Parameters should end with a blank comment ***ERROR
  #
  # === Parameters:
  #
  # * <tt>:arg1</tt> First Parameter
  def missing_blank_comment_parameters_no_parameters(arg1)
    uuu(arg1)
  end

  # Illegal Parameters syntax ***ERROR
  #
  # ===  Parameters:
  #
  # * <tt>:arg1</tt> First Parameter
  #
  def illegal_parameters_syntax(arg1)
    uuu(arg1)
  end

  # Missing first blank company ***ERROR
  #
  # === Parameters:
  # * <tt>:arg1</tt> First Parameter
  #
  def missing_first_blank_comment_parameters(arg1)
    uuu(arg1)
  end
end
