class AddPickConfirmationNameEvent < ActiveRecord::Migration
  def up
    AppFactory.add_confirmation_event(I18n.t('events.confirmation_name'))

    create_table :pick_confirmation_names do |t|
      t.string :saint_name
      t.text :about_saint
      t.text :why_saint
      t.string :pick_confirmation_name_filename
      t.string :pick_confirmation_name_content_type
      t.binary :pick_confirmation_name_file_contents

      t.timestamps null: false
    end

    add_reference(:candidates, :pick_confirmation_name, index: true)
    add_foreign_key(:candidates, :pick_confirmation_names)
  end

  def down
    AppFactory.revert_confirmation_event(I18n.t('events.confirmation_name'))
    remove_foreign_key(:candidates, :pick_confirmation_names)
    remove_reference(:candidates, :pick_confirmation_name)
    drop_table(:pick_confirmation_names)
  end
end
