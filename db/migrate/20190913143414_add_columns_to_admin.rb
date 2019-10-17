class AddColumnsToAdmin < ActiveRecord::Migration[5.2]
  def change
    add_column :admins, :contact_name, :string, null: false, default: ''
    add_column :admins, :contact_phone, :string, null: false, default: ''
  end
end
