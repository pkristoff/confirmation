class AddCandidateColumns < ActiveRecord::Migration
  def change
    remove_index 'candidates', column: 'email'
    remove_index 'candidates', column: 'name'
    remove_index 'candidates', column: 'reset_password_token'
    rename_column(:candidates, :name, :candidate_id)
    add_column(:candidates, :first_name, :string, default: '', null: false)
    add_column(:candidates, :last_name, :string, default: '', null: false)
    add_column(:candidates, :grade, :decimal, precision:2)
    add_column(:candidates, :candidate_email, :string, default: '', null: false)
    add_column(:candidates, :parent_email_2, :string, default: '', null: false)
    add_column(:candidates, :attending, :string, default: 'The Way', null: false)
    rename_column(:candidates, :email, :parent_email_1)

    add_index 'candidates', [:candidate_id], name: 'index_candidates_on_candidate_id', unique: true, using: :btree
    add_index 'candidates', [:reset_password_token], name: 'index_candidates_on_reset_password_token', unique: true, using: :btree
  end
end
