class AddParentInformationMeeting < ActiveRecord::Migration
  def up
    AppFactory.add_parent_information_meeting_migration
  end

  def down
    puts 'reverting'
    Candidate.all.each do |candidate|
      puts "reverting candidate: #{candidate.account_name}"
      found = candidate.candidate_events.find { |candidate_event| candidate_event.name == 'Parent Information Meeting' }
      puts "found candidate_event: #{found.name}" unless found.nil?
      puts "NOT found candidate_event" if found.nil?
      unless found.nil?
        puts "removing and destroying"
        candidate.candidate_events.delete(found)
        found.destroy
      end

    end
    puts 'about to destroy'
    confirmation_event = ConfirmationEvent.find_by(name: 'Parent Information Meeting')
    confirmation_event.destroy
    puts 'done reverting'
  end
end
