class RenameCandiatesColumnCandiateId < ActiveRecord::Migration
  def change
    remove_index 'candidates', column: 'candidate_id'
    rename_column(:candidates, :candidate_id, :account_name)
    add_index 'candidates', [:account_name], name: 'index_candidates_on_account_name', unique: true, using: :btree

    change_table :candidate_events do | t |
      t.belongs_to :candidate, index: true
    end

  end
end
