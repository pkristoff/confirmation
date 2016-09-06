class RenameSignAgreement < ActiveRecord::Migration
  def up
    event = ConfirmationEvent.find_by_name('Sign Agreement')
    event.name='Candidate Covenant Agreement'
    event.save
  end
  def down
    event = ConfirmationEvent.find_by_name('Candidate Covenant Agreement')
    event.name='Sign Agreement'
    event.save
  end
end
