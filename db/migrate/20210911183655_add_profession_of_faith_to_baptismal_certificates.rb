class AddProfessionOfFaithToBaptismalCertificates < ActiveRecord::Migration[5.2]
  def change
    remove_column :baptismal_certificates, :first_comm_at_home_parish
    add_column :baptismal_certificates, :baptized_catholic, :boolean, default: false,null: false
    add_column :baptismal_certificates, :prof_church_name, :string, default: nil
    add_column :baptismal_certificates, :prof_date, :date, default: nil

    add_reference(:baptismal_certificates, :scanned_prof, references: :scanned_images, index: true)
    add_reference(:baptismal_certificates, :prof_church_address, references: :addresses, index: true)
  end
end
