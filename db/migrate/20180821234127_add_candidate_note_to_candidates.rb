class AddCandidateNoteToCandidates < ActiveRecord::Migration[5.2]
  def change
    add_column :candidates, :candidate_note, :text, null: false, default: ''
  end
end
