class RenameSignAgreement < ActiveRecord::Migration
  def up
    event = ConfirmationEvent.find_by_name('Sign Agreement')
    unless event.nil?
      event.name='Candidate Covenant Agreement'
      event.save
    end
  end

  def down
    event = ConfirmationEvent.find_by_name('Candidate Covenant Agreement')
    unless event.nil?
      event.name='Sign Agreement'
      event.save
    end
  end
end
