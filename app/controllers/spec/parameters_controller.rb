# frozen_string_literal: true

# A fixture used by rubocop extensions to test
# uniformity of documentation
#
class ParametersController < ApplicationController
  # legal parameters
  #
  # === Parameters:
  #
  # * <tt>:arg1</tt> First Parameter
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

  # Missing body ***ERROR
  #
  # === Parameters:
  #
  def missing_body_parameters(arg1)
    uuu(arg1)
  end

  # legal sub-lines ***ERROR
  #
  # === Parameters:
  #
  # * <tt>:arg1</tt> Legal Values
  # ** <code>:one</code> when desc one
  # ** <code>:two</code> when desc two
  #
  def legal_sub_parameters(arg1)
    uuu(arg1)
  end
end
