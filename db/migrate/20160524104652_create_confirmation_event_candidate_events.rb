class CreateConfirmationEventCandidateEvents < ActiveRecord::Migration
  def change
    create_table :to_dos do |t|
      t.belongs_to :confirmation_event, index: true
      t.belongs_to :candidate_event, index: true

      t.timestamps null: false
    end
  end
end
