class CreateConfirmationEvents < ActiveRecord::Migration
  def change
    create_table :confirmation_events do |t|
      t.string :name, index: true
      t.date :due_date

      t.timestamps null: false
    end
  end
end
