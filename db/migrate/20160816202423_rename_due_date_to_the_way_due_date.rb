class RenameDueDateToTheWayDueDate < ActiveRecord::Migration
  def change
    rename_column(:confirmation_events, :due_date, :the_way_due_date)
    add_column(:confirmation_events, :chs_due_date, :date)
  end
end
