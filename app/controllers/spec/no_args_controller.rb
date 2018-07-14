# frozen_string_literal: true

#
# Handles Common Application tasks
#
class NoArgsController < ApplicationController
  # Legal no argument method
  #
  def no_args
    uuu
  end

  # Legal no arguments with Returns
  #
  # === Returns:
  #
  # * <tt>send_data</tt> for spreadsheet
  #
  def no_args_with_returns
    uuu
  end
end
