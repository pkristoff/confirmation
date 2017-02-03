class AddMiddleNameToCandidateSheet < ActiveRecord::Migration
  def change
    add_column :candidate_sheets, :middle_name, :string, null: false, default: ''
  end
end
