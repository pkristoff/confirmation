class AddChristianMinistryEvent < ActiveRecord::Migration
  def up
    AppFactory.add_confirmation_event(I18n.t('events.christian_ministry'))
    create_table :christian_ministries do |t|
      t.boolean :signed, null: false, default: true
      t.text :what_service
      t.text :where_service
      t.text :when_service
      t.text :helped_me
      t.string :christian_ministry_filename
      t.string :christian_ministry_content_type
      t.binary :christian_ministry_file_contents
      t.timestamps null: false
    end

    add_reference(:candidates, :christian_ministry, index: true)
    add_foreign_key(:candidates, :christian_ministries)

    Candidate.all.each do |candidate|
      candidate.build_christian_ministry
      candidate.save(validate: false)
    end

  end

  def down
    remove_foreign_key(:candidates, :christian_ministries)
    remove_reference(:candidates, :christian_ministry)
    drop_table(:christian_ministries)
  end
end
