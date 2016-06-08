class RenameAdminConfirmedToVerified < ActiveRecord::Migration
  def change
    rename_column :candidate_events, :admin_confirmed, :verified
  end
end
