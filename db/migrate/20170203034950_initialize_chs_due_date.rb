class InitializeChsDueDate < ActiveRecord::Migration
  def change
    ConfirmationEvent.all.each do | confirmation_event |
      if confirmation_event.chs_due_date.nil?
        puts "confirmation_event chs_due_date being update: #{confirmation_event.name}"
        confirmation_event.chs_due_date = confirmation_event.the_way_due_date
      end
    end
  end
end
