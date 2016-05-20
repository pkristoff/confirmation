class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.string :street_1, :string, null: false, default: ''
      t.string :street_2, :string, null: false, default: ''
      t.string :city, :string, null: false, default: 'Apex'
      t.string :state, :string, null: false, default: 'NC'
      t.string :zip_code, :string, null: false, default: '27502'

      t.timestamps null: false
    end

    add_reference(:candidates, :address, index: true)
    add_foreign_key(:candidates, :addresses)

    # for some reason the above generated an extra colomn names string.
    remove_column :addresses, :string, :string
  end
end
