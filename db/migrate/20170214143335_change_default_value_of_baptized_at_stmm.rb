class ChangeDefaultValueOfBaptizedAtStmm < ActiveRecord::Migration
  def up
    change_column :candidates, :baptized_at_stmm, :boolean, :default => false
  end

  def down
    change_column :candidates, :baptized_at_stmm, :boolean, :default => true
  end
end
