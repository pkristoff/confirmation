class AddNameToAdmins < ActiveRecord::Migration
  def change
    add_column :admins, :name, :string
    add_index :admins, :name, unique: true
  end
end
