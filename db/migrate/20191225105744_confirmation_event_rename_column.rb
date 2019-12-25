class ConfirmationEventRenameColumn < ActiveRecord::Migration[5.2]
  def change

    rename_column :confirmation_events, :name, :event_key

    ConfirmationEvent.all.each do |confirmation_event|
      old_event_key = confirmation_event.event_key
      puts "searching #{old_event_key}"
      case old_event_key
      when 'Parent Information Meeting'
        confirmation_event.event_key = Candidate.parent_meeting_event_key
      when 'Candidate Covenant Agreement'
        confirmation_event.event_key = Candidate.covenant_agreement_event_key
      when 'Attend Retreat'
        puts 'found'
        confirmation_event.event_key = RetreatVerification.event_key
      when 'Candidate Information Sheet'
        confirmation_event.event_key = CandidateSheet.event_key
      when 'Baptismal Certificate'
        confirmation_event.event_key = BaptismalCertificate.event_key
      when 'Sponsor Covenant & Sponsor Eligibility'
        confirmation_event.event_key = SponsorCovenant.event_key
      when 'Confirmation Name'
        confirmation_event.event_key = PickConfirmationName.event_key
      when 'Christian Ministry Awareness'
        confirmation_event.event_key = ChristianMinistry.event_key
      else
        raise("unknown old_event_key: #{old_event_key}")
      end
      confirmation_event.save
    end
  end
end
