class AddNameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :name, :string
    add_index :admins, :name, unique: true
  end
end
