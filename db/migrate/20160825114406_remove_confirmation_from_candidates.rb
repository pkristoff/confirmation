class RemoveConfirmationFromCandidates < ActiveRecord::Migration
  def up
    remove_column(:candidates, :confirmation_name, :string)
    AppFactory.revert_confirmation_event('Confirmation Name')

    # create_table :confirmation_names do |t|
    #   t.string :saint_name
    #   t.text :about_saint
    #   t.text :why_saint
    #   t.string :confirmation_name_filename
    #   t.string :confirmation_name_content_type
    #   t.binary :confirmation_name_file_contents
    #
    #   t.timestamps null: false
    # end

    # add_reference(:candidates, :confirmation_name, index: true)
    # add_foreign_key(:candidates, :confirmation_names)
  end

  def down
    add_column(:candidates, :confirmation_name, :string, default: '', null: false)
    AppFactory.add_confirmation_event('Confirmation Name')
  end
end
