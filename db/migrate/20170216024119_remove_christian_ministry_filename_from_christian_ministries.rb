class RemoveChristianMinistryFilenameFromChristianMinistries < ActiveRecord::Migration
  def change
    remove_column :christian_ministries, :signed, :boolean
    remove_column :christian_ministries, :christian_ministry_filename, :string
    remove_column :christian_ministries, :christian_ministry_content_type, :string
    remove_column :christian_ministries, :christian_ministry_file_contents, :binary
  end
end
