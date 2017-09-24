class CreateScannedImages < ActiveRecord::Migration
  def change
    create_table :scanned_images do |t|
      t.string :filename
      t.string :content_type
      t.binary :content

      t.timestamps null: false
    end

    add_reference(:baptismal_certificates, :scanned_certificate, references: :scanned_images, index: true)
    add_reference(:retreat_verifications, :scanned_retreat, references: :scanned_images, index: true)
    add_reference(:sponsor_covenants, :scanned_eligibility, references: :scanned_images, index: true)
    add_reference(:sponsor_covenants, :scanned_covenant, references: :scanned_images, index: true)

  end
end
