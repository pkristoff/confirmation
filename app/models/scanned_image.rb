# frozen_string_literal: true

#
# Active Record
#
class ScannedImage < ActiveRecord::Base
  belongs_to(:retreat_verification)
  belongs_to(:baptismal_certificate)
  belongs_to(:sponsor_covenant)

  # Editable attributes
  #
  # === Returns:
  #
  # Array of attributes
  #
  def self.permitted_params
    %i[filename content_type content id]
  end
end
