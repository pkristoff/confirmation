# frozen_string_literal: true

# A fixture used by rubocop extensions to test
# uniformity of documentation
#
class BasicDocController < ActionController
  # Should not generate any offenses
  #
  def legal_no_args
    uuu
  end

  #
  # Description should not begin with an blank comment
  #
  def description_begins_with_empty_comment
    uuu
  end

  # Description should end with a blank comment
  def description_does_not_end_with_empty_comment
    uuu
  end

  # Should not generate any offenses
  #
  # === Parameters:
  #
  # * <tt>:arg1</tt> First Parameter
  #
  def legal_parameters(arg1)
    uuu(arg1)
  end

  # Missing blank comment at end of Parameters
  #
  # === Parameters:
  #
  # * <tt>:arg1</tt> First Parameter
  def missing_blank_comment_parameters(arg1)
    uuu(arg1)
  end

  # Illegal Parameters syntax
  #
  #  ===  Parameters:
  #
  # * <tt>:arg1</tt> First Parameter
  #
  def illegal_parameters_syntax(arg1)
    uuu(arg1)
  end

  # Should not generate any offenses
  #
  # === Parameters:
  #
  # * <tt>:arg1</tt> First Parameter
  #
  # === Returns:
  #
  # send_data for spreadsheet
  #
  def legal_parameters_with_returns(arg1)
    uuu(arg1)
  end

  # Should not generate any offenses
  #
  # === Returns:
  #
  # send_data for spreadsheet
  #
  def legal_returns_no_parameters
    uuu
  end

  # Returns should end with a blank comment
  #
  # === Returns:
  #
  # send_data for spreadsheet
  def missing_blank_comment_returns_no_parameters
    uuu
  end

  # Illegal Returns syntax
  #
  # ===  Returns:
  #
  # send_data for spreadsheet
  #
  def illegal_returns_syntax
    uuu
  end
end
