# frozen_string_literal: true

# A fixture used by rubocop extensions to test
# uniformity of documentation
#
class ReturnsController < ActionController
  # legal returns
  #
  # === Returns:
  #
  # * <tt>send_data</tt> for spreadsheet
  #
  def legal_returns_syntax
    uuu
  end

  # legal multiple returns
  #
  # === Returns:
  #
  # * <tt>Boolen</tt>
  # * <tt>String</tt> xxx
  # * <tt>Axlsx::Package</tt>
  #
  def legal_multiple_returns_syntax
    uuu
  end

  # legal multiple returns
  #
  # === Returns:
  #
  # * <tt>String</tt> legal values
  # ** <code>:one</code> legal
  # ** <code>AAA</code>
  # ** <code>BBB</code>
  # ** <code>DDD</code>
  #
  def legal_sub_values
    uuu
  end

  # Returns should end with a blank comment ***ERROR
  #
  # === Returns:
  #
  # * <tt>send_data</tt> for spreadsheet
  def missing_blank_comment_returns_no_parameters
    uuu
  end

  # Illegal Returns syntax ***ERROR
  #
  # ===  Returns:
  #
  # * <tt>send_data</tt> for spreadsheet
  #
  def illegal_returns_syntax
    uuu
  end

  # Missing final blank company ***ERROR
  #
  # === Returns:
  # * <tt>send_data</tt> for spreadsheet
  #
  def missing_first_blank_comment_returns
    uuu
  end

  # Illegal sub-format ***ERROR
  #
  # === Returns:
  #
  # * <tt>String</tt> for spreadsheet
  # ** <tt>:one</tt> when desc one - illegal
  #
  def illegal_sub_format_returns
    uuu
  end
end
