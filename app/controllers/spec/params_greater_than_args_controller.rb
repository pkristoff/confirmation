# frozen_string_literal: true

#
# Handles Common Application tasks
#
class ParamsGreaterThanArgsController < ActionController
  # This will raise one offense that the documented parm size does not match the
  # number of arguments specified.
  #
  # === Parameters:
  #
  # * <tt>_arg1_</tt> First Parameter
  # * <tt>_parm2_</tt> Second Parameter
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
  # * <tt>_parm1_</tt> First Parameter
  # * <tt>_parm2_</tt> Second Parameter
  #
  def params_greater_than_args_name_mismatch(arg1)
    uuu(arg1)
  end
end
