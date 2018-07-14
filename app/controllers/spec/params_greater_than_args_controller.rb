# frozen_string_literal: true

#
# Handles Common Application tasks
#
class ParamsGreaterThanArgsController < ApplicationController
  # This will raise one offense that the documented parm size does not match the
  # number of arguments specified.
  #
  # === Parameters:
  #
  # * <tt>:arg1</tt> First Parameter
  # * <tt>:parm2</tt> Second Parameter
  #
  def params_greater_than_args(arg1)
    uuu(arg1)
  end

  # This should raise two offenses
  #   - There are more parms documented than there are args specified.
  #   - The first parm name documented does not match the arg specified(arg1)
  #
  # === Parameters:
  #
  # * <tt>:parm1</tt> First Parameter
  # * <tt>:parm2</tt> Second Parameter
  #
  def params_greater_than_args_name_mismatch(arg1)
    uuu(arg1)
  end
end
