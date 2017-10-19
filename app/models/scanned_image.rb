class ScannedImage < ActiveRecord::Base
  belongs_to(:retreat_verification)
  belongs_to(:baptismal_certificate)
  belongs_to(:sponsor_covenant)

  def self.get_permitted_params
    [:filename, :content_type , :content, :id]
  end
end
