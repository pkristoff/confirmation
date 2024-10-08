# renaming ConfirmationEvents columns:
#     the_way_due_date --> progrem_year1_due_date
#     chs_due_date --> progrem_year2_due_date
#
class RenameConfirmationEventsDueDate < ActiveRecord::Migration[6.1]
  # renaming ConfirmationEvents columns:
  #     the_way_due_date --> program_year1_due_date
  #     chs_due_date --> program_year2_due_date
  #
  def change
    rename_column(:confirmation_events, :the_way_due_date, :program_year1_due_date)
    rename_column(:confirmation_events, :chs_due_date, :program_year2_due_date)
  end
end
