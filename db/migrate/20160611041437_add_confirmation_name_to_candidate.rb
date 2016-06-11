class AddConfirmationNameToCandidate < ActiveRecord::Migration
  def change
    add_column(:candidates, :confirmation_name, :string, null: false, default: '' )
  end
end
