class CreateRetreatVerifications < ActiveRecord::Migration
  def change
    #TODO: remove add
    AppFactory.add_confirmation_event(I18n.t('events.retreat_verification'))

    create_table :retreat_verifications do |t|
      t.boolean :retreat_held_at_stmm, null: false, default: false
      t.date :start_date
      t.date :end_date
      t.string :who_held_retreat
      t.string :where_held_retreat
      t.string :retreat_filename
      t.string :retreat_content_type
      t.string :retreat_file_content

      t.timestamps null: false
    end

    add_reference(:candidates, :retreat_verification, index: true, foreign_key: true)

    Candidate.reset_column_information
    Candidate.all.each do |candidate|
      candidate.update_attribute(:retreat_verification, RetreatVerification.new)
    end
  end
end
