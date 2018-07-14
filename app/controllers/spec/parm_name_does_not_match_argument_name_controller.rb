# frozen_string_literal: true

#
# Handles Common Application tasks
#
class ParmNameDoesNotMatchArgumentNameController < ApplicationController
  # legal
  #
  # === Parameters:
  #
  # * <tt>:arg1</tt> First Parameter
  #
  def param_and_arg_name_good(arg1)
    uuu(arg1)
  end

  # Parameter does not match arg
  #
  # === Parameters:
  #
  # * <tt>:parm1</tt> First Parameter
  #
  def param_and_arg_name(arg1)
    uuu(arg1)
  end

  # First Parameter does not match first argument
  #
  # === Parameters:
  #
  # * <tt>:parm1</tt> First Parameter
  # * <tt>:same</tt> Second Parameter
  #
  def first_param_and_arg_name(arg1, same)
    uuu(arg1, same)
  end

  # Second Parameter does not match second argument
  #
  # === Parameters:
  #
  # * <tt>:same</tt> First Parameter
  # * <tt>:parm2</tt> Second Parameter
  #
  def second_param_and_arg_name(same, arg2)
    uuu(same, arg2)
  end

  # Legal unused argument
  #
  # === Parameters:
  #
  # * <tt>:same</tt> First Parameter
  # * <tt>:arg2</tt> Second Parameter
  #
  def unused_argument(same, _arg2)
    uuu(same)
  end

  # Illegal unused argument
  #
  # === Parameters:
  #
  # * <tt>:same</tt> First Parameter
  # * <tt>:_arg2</tt> Second Parameter
  #
  def illegal_unused_argument(same, _arg2)
    uuu(same)
  end

  # legal
  #
  # === Parameters:
  #
  # * <tt>:arg2</tt> First Parameter
  # * <tt>:arg1</tt> Second Parameter
  #
  def param_and_arg_name_order(arg1, arg2)
    uuu(arg1, arg2)
  end
end
