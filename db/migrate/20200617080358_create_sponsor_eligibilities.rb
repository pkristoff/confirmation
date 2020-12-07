class CreateSponsorEligibilities < ActiveRecord::Migration[5.2]
  def change
    connection.execute 'drop table if exists sponsor_eligibilities'
    create_table :sponsor_eligibilities do |t|
      t.boolean :sponsor_attends_home_parish, null: false, default: true
      t.string :sponsor_church, null: false, default: ''

      t.timestamps
    end
    add_reference(:candidates, :sponsor_eligibility, index: true, type: :integer)
    add_foreign_key(:candidates, :sponsor_eligibilities)
    add_reference(:sponsor_eligibilities, :scanned_eligibility, type: :integer)

    old_key = 'sponsor_covenant_and_sponsor_eligibility'
    reversible do |dir|
      dir.up do

        # add new ConfirmationEvent
        if ConfirmationEvent.all.size > 0
          if ConfirmationEvent.all.size > 0
            AppFactory.add_confirmation_event(SponsorEligibility.event_key)
          end
        end
        say 'add_confirmation_event-event_keys-end'

        # build new class in candidate and set new values
        Candidate.all.each do |candidate|
          say "candidate.account_name=#{candidate.account_name}"
          candidate.build_sponsor_eligibility
          candidate.sponsor_eligibility.sponsor_attends_home_parish = candidate.sponsor_covenant.sponsor_attends_home_parish
          candidate.sponsor_eligibility.sponsor_church = candidate.sponsor_covenant.sponsor_church.nil? ? '' : candidate.sponsor_covenant.sponsor_church
          candidate.sponsor_eligibility.scanned_eligibility = candidate.sponsor_covenant.scanned_eligibility
          sponsor_covenant_event = candidate.get_candidate_event(old_key)

          if sponsor_covenant_event.verified
            say "  verified=#{CandidateEvent.status(sponsor_covenant_event.due_date, sponsor_covenant_event.completed_date, sponsor_covenant_event.verified)}"
          else
            if sponsor_covenant_event.completed_date.nil?
              sponsor_covenant_event.mark_completed(candidate.validate_event_complete(SponsorCovenant), SponsorCovenant)
              say "  mark_completed=#{CandidateEvent.status(sponsor_covenant_event.due_date, sponsor_covenant_event.completed_date, sponsor_covenant_event.verified)}"
            else
              sponsor_covenant_event.verified = true
              say "  set verified=#{CandidateEvent.status(sponsor_covenant_event.due_date, sponsor_covenant_event.completed_date, sponsor_covenant_event.verified)}"
            end
          end
          sponsor_eligibility_event = candidate.get_candidate_event(SponsorEligibility.event_key)
          sponsor_eligibility_event.completed_date = sponsor_covenant_event.completed_date
          sponsor_eligibility_event.verified = sponsor_covenant_event.verified
          candidate.save(validate: false)
        end

        # change old_key back to new key_event for SponsorCovenant
        if ConfirmationEvent.all.size > 0
          cove_event = ConfirmationEvent.find_by(event_key: old_key)
          new_key = SponsorCovenant.event_key
          cove_event.event_key = new_key if cove_event
          cove_event.save if cove_event
          raise(RuntimeError, "Confirmation Event not found: #{old_key} (old key)") unless cove_event

          eligi_event = ConfirmationEvent.find_by(event_key: SponsorEligibility.event_key)
          eligi_event.the_way_due_date = cove_event.the_way_due_date
          eligi_event.chs_due_date = cove_event.chs_due_date
        end

      end
      dir.down do
        # move values back to SponsorCovenant
        Candidate.all.each do |candidate|
          candidate.sponsor_covenant.sponsor_attends_home_parish = candidate.sponsor_eligibility.sponsor_attends_home_parish
          candidate.sponsor_covenant.sponsor_church = candidate.sponsor_eligibility.sponsor_church
          candidate.sponsor_covenant.scanned_eligibility = candidate.sponsor_eligibility.scanned_eligibility

          sponsor_covenant_event = candidate.get_candidate_event(SponsorCovenant.event_key)
          sponsor_eligibility_event = candidate.get_candidate_event(SponsorEligibility.event_key)
          sponsor_covenant_event.completed_date = sponsor_eligibility_event.completed_date
          sponsor_covenant_event.verified = sponsor_eligibility_event.verified
          candidate.save(validate: false)
        end
        # get rid of new CandidateEvent
        if ConfirmationEvent.all.size > 0
          if ConfirmationEvent.find_by(event_key: SponsorEligibility.event_key)
            AppFactory.revert_confirmation_event(SponsorEligibility.event_key)
          else
            raise(RuntimeError, "Confirmation Event not found: #{event_key} (event key)")
          end
        end
        if ConfirmationEvent.all.size > 0
          # change new_key back to old key_event for SponsorCovenant
          new_key = SponsorCovenant.event_key
          ce = ConfirmationEvent.find_by(event_key: new_key)
          ce.event_key = old_key if ce
          ce.save if ce
          raise(RuntimeError, "Confirmation Event not found: #{new_key} (new key)") unless ce
        end
      end
    end

    remove_reference(:sponsor_covenants, :scanned_eligibility)
    remove_column :sponsor_covenants, :sponsor_attends_home_parish, :boolean
    remove_column :sponsor_covenants, :sponsor_church, :string
  end
end
