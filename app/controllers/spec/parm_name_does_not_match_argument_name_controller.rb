# frozen_string_literal: true

#
# Handles Common Application tasks
#
class ParmNameDoesNotMatchArgumentNameController < ActionController
  # description
  #
  # === Parameters:
  #
  # * <tt>_arg1_</tt> First Parameter
  #
  def param_and_arg_name_good(arg1)
    uuu(arg1)
  end

  # description
  #
  # === Parameters:
  #
  # * <tt>_parm1_</tt> First Parameter
  #
  def param_and_arg_name(arg1)
    uuu(arg1)
  end

  # description
  #
  # === Parameters:
  #
  # * <tt>_parm1_</tt> First Parameter
  # * <tt>_same_</tt> Second Parameter
  #
  def first_param_and_arg_name(arg1, same)
    uuu(arg1, same)
  end

  # description
  #
  # === Parameters:
  #
  # * <tt>_same_</tt> First Parameter
  # * <tt>_parm2_</tt> Second Parameter
  #
  def second_param_and_arg_name(same, arg2)
    uuu(same, arg2)
  end

  # description
  #
  # === Parameters:
  #
  # * <tt>_arg2_</tt> First Parameter
  # * <tt>_arg1_</tt> Second Parameter
  #
  def param_and_arg_name_order(arg1, arg2)
    uuu(arg1, arg2)
  end
end
