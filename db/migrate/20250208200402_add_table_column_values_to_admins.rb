# add column to Admin
#
class AddTableColumnValuesToAdmins < ActiveRecord::Migration[6.1]
  # qdd column to Admin
  #
  def change
    add_column :admins, :table_filter_and_sorting_columns, :string
  end
end
