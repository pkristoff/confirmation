class RemovePickConfirmationNameFilenameFromPIckConfirmationNames < ActiveRecord::Migration
  def change
    remove_column :pick_confirmation_names, :about_saint, :string
    remove_column :pick_confirmation_names, :why_saint, :string
    remove_column :pick_confirmation_names, :pick_confirmation_name_filename, :string
    remove_column :pick_confirmation_names, :pick_confirmation_name_content_type, :string
    remove_column :pick_confirmation_names, :pick_confirmation_name_file_contents, :binary
  end
end
