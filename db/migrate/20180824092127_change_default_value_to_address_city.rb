class ChangeDefaultValueToAddressCity < ActiveRecord::Migration[5.2]
  def change
    change_column :addresses, :city, :string, default: '', null: false
    change_column :addresses, :state, :string, default: '', null: false
    change_column :addresses, :zip_code, :string, default: '', null: false
  end
end
