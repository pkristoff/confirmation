# frozen_string_literal: true

# A fixture used by rubocop extensions to test
# uniformity of documentation
#
class ReturnsController < ActionController
  # legal returns
  #
  # === Returns:
  #
  # send_data for spreadsheet
  #
  def legal_returns_syntax
    uuu
  end

  # Returns should end with a blank comment ***ERROR
  #
  # === Returns:
  #
  # send_data for spreadsheet
  def missing_blank_comment_returns_no_parameters
    uuu
  end

  # Illegal Returns syntax ***ERROR
  #
  # ===  Returns:
  #
  # send_data for spreadsheet
  #
  def illegal_returns_syntax
    uuu
  end

  # Missing final blank company ***ERROR
  #
  # === Returns:
  # send_data for spreadsheet
  #
  def missing_first_blank_comment_returns
    uuu
  end
end
