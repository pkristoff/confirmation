class RenameFillOutCandidateInformationSheet < ActiveRecord::Migration
  def up
    event = ConfirmationEvent.find_by_name('Fill Out Candidate Information Sheet')
    event.name='Candidate Information Sheet'
    event.save
  end
  def down
    event = ConfirmationEvent.find_by_name('Candidate Information Sheet')
    event.name='Fill Out Candidate Information Sheet'
    event.save
  end
end
