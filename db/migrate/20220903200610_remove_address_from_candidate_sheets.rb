class RemoveAddressFromCandidateSheets < ActiveRecord::Migration[6.1]
  def up
    remove_index :candidate_sheets, :address_id
    remove_column :candidate_sheets, :address_id, type: :integer
  end
  def down
    add_reference(:candidate_sheets, :address, references: :addresses, index: true)
  end
end
