class CreateBaptismalCertificates < ActiveRecord::Migration
  def change
    create_table :baptismal_certificates do |t|
      t.date :birth_date
      t.date :baptismal_date
      t.string :church_name
      t.string :father_first
      t.string :father_last
      t.string :father_middle
      t.string :mother_first
      t.string :mother_middle
      t.string :mother_maiden
      t.string :mother_last
      t.string :certificate_filename
      t.string :certificate_content_type
      t.binary :certificate_file_contents

      t.timestamps null: false
    end

    add_reference(:candidates, :baptismal_certificate, index: true)
    add_foreign_key(:candidates, :baptismal_certificates)

    add_reference(:baptismal_certificates, :church_address, references: :addresses, index: true)
  end
end
