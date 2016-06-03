class CreateCandidateEvents < ActiveRecord::Migration
  def change
    create_table :candidate_events do |t|
      t.date :completed_date
      t.boolean :admin_confirmed

      t.timestamps null: false
    end
  end
end
