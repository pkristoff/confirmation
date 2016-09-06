class RenamePickConfirmationName < ActiveRecord::Migration
  def up
    event = ConfirmationEvent.find_by_name('Pick Confirmation Name')
    unless event.nil?
      event.name='Confirmation Name'
      event.save
    end
  end

  def down
    event = ConfirmationEvent.find_by_name('Confirmation Name')
    unless event.nil?
      event.name='Pick Confirmation Name'
      event.save
    end
  end
end
