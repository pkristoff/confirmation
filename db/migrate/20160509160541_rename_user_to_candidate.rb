class RenameUserToCandidate < ActiveRecord::Migration
  def change
    rename_table(:users, :candidates)
    add_index :candidates, :email,                unique: true
    add_index :candidates, :reset_password_token, unique: true
  end
end
