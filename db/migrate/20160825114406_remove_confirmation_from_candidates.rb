class RemoveConfirmationFromCandidates < ActiveRecord::Migration
  def up
    remove_column(:candidates, :confirmation_name, :string)
    AppFactory.revert_confirmation_event('Confirmation Name')
  end

  def down
    add_column(:candidates, :confirmation_name, :string, default: '', null: false)
    AppFactory.add_confirmation_event('Confirmation Name')
  end
end
