class AddAccountNameToAdmin < ActiveRecord::Migration[5.2]
  def change
    add_column :admins, :account_name, :string, null: false, default: 'Admin'
  end
end
