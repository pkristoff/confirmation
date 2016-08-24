class AddFileColumnsToSponsorCovenants < ActiveRecord::Migration
  def change
    add_column(:sponsor_covenants, :sponsor_covenant_filename, :string)
    add_column(:sponsor_covenants, :sponsor_covenant_content_type, :string)
    add_column(:sponsor_covenants, :sponsor_covenant_file_contents, :binary)
  end
end
