# frozen_string_literal: true

#
# Handles Common Application tasks
#
class ParamsLessThanArgsController < ActionController
  # should generate offense that Paremetes is less than arguments
  #
  # === Parameters:
  #
  # * <tt>:arg1</tt> First Parameter
  #
  def params_less_than_args(arg1, arg2)
    uuu(arg1, arg2)
  end

  # should generate offense
  #   - Paremeters is less than arguments
  #   - Parm1 does not match arg1
  #
  # === Parameters:
  #
  # * <tt>:parm1</tt> First Parameter
  #
  def params_less_than_args_2(arg1, arg2)
    uuu(arg1, arg2)
  end
end
