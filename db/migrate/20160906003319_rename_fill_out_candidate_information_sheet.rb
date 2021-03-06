class RenameFillOutCandidateInformationSheet < ActiveRecord::Migration
  def up
    event = ConfirmationEvent.find_by(name: 'Fill Out Candidate Information Sheet')
    unless event.nil?
      event.name='Candidate Information Sheet'
      event.save
    end
  end

  def down
    event = ConfirmationEvent.find_by(name: 'Candidate Information Sheet')
    unless event.nil?
      event.name='Fill Out Candidate Information Sheet'
      event.save
    end
  end
end
