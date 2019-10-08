class AddAccountNameToAdmin < ActiveRecord::Migration[5.2]
  def change
    add_column :admins, :account_name, :string, null: false, default: 'Admin'
    Admin.all.each_with_index do |admin, i|
      Rails.logger.info("admin.account_name=#{admin.account_name}")
      admin.account_name = 'Admin' if i == 0
      admin.account_name = "Admin#{i}" if i == 0
      admin.save
    end
  end
end
