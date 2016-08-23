class AddSponsorCovenant < ActiveRecord::Migration
  def up
    AppFactory.add_confirmation_event(I18n.t('events.upload_sponsor_covenant'))
    create_table :sponsor_covenants do |t|
      t.string :sponsor_name
      t.boolean :sponsor_attends_stmm, null: false, default: true
      t.string :sponsor_church
      t.string :sponsor_elegibility_filename
      t.string :sponsor_elegibility_content_type
      t.binary :sponsor_elegibility_file_contents
      t.timestamps null: false
    end

    add_reference(:candidates, :sponsor_covenant, index: true)
    add_foreign_key(:candidates, :sponsor_covenants)

    Candidate.all.each do |candidate|
      candidate.build_sponsor_covenant
      candidate.save(validate: false)
    end

  end

  def down
    remove_foreign_key(:candidates, :sponsor_covenants)
    remove_reference(:candidates, :sponsor_covenant)
    drop_table(:sponsor_covenants)
  end
end
