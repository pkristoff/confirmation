class AddInstructionsToConfirmationEvent < ActiveRecord::Migration
  def change
    add_column(:confirmation_events, :instructions, :text, null: false, default: '')
  end
end
