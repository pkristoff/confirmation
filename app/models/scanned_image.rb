#
# Actve Record
#
class ScannedImage < ActiveRecord::Base
  belongs_to(:retreat_verification)
  belongs_to(:baptismal_certificate)
  belongs_to(:sponsor_covenant)

  # Editable attributes
  #
  # === Return:
  #
  # Array of attributes
  #
  def self.get_permitted_params
    [:filename, :content_type, :content, :id]
  end
end
