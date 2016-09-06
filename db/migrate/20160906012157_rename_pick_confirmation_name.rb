class RenamePickConfirmationName < ActiveRecord::Migration
  def up
    event = ConfirmationEvent.find_by_name('Pick Confirmation Name')
    event.name='Confirmation Name'
    event.save
  end
  def down
    event = ConfirmationEvent.find_by_name('Confirmation Name')
    event.name='Pick Confirmation Name'
    event.save
  end
end
