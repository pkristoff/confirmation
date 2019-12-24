class AddProgramYearToCandidateSheet < ActiveRecord::Migration[5.2]
  def change
    add_column :candidate_sheets, :program_year, :decimal, precision: 1, default: 2, null: false
    Candidate.all.each do |cand|
      cand.candidate_sheet.program_year = 2
    end

    rename_column :confirmation_events, :name, :event_key

    ConfirmationEvent.all.each do |confirmation_event|
      old_event_key = confirmation_event.event_key
      case old_event_key
      when 'Parent Information Meeting'
        confirmation_event.event_key = Candidate.parent_meeting_event_key
      when 'Candidate Covenant Agreement'
        confirmation_event.event_key = Candidate.covenant_agreement_event_key
      when 'Attend Retreat'
        confirmation_event.event_key = Candidate.covenant_agreement_event_key
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
    end
  end
end
