class CreateConfirmationEventCandidateEvents < ActiveRecord::Migration
  def change
    create_table :confirmation_event_candidate_events do |t|
      t.belongs_to :confirmation_event, index: true
      t.belongs_to :candidate_event, index: true

      t.timestamps null: false
    end
  end
end
