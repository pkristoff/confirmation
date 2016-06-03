class RenameUserToCandidate < ActiveRecord::Migration
  def change
    rename_table(:users, :candidates)
  end
end
