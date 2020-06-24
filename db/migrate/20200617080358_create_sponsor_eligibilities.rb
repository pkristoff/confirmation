class CreateSponsorEligibilities < ActiveRecord::Migration[5.2]
  def change
    ConfirmationEvent.all.each do |ce|
      say ce.event_key
    end
    create_table :sponsor_eligibilities do |t|
      t.boolean :sponsor_attends_home_parish, null: false, default: true
      t.string :sponsor_church, null: false, default: ''

      t.timestamps
    end
    add_reference(:candidates, :sponsor_eligibility, index: true, type: :integer)
    add_foreign_key(:candidates, :sponsor_eligibilities)
    remove_reference(:sponsor_covenants,:scanned_eligibility)
    add_reference(:sponsor_eligibilities,:scanned_eligibility, type: :integer)

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
          candidate.build_sponsor_eligibility
          candidate.sponsor_eligibility.sponsor_attends_home_parish = candidate.sponsor_covenant.sponsor_attends_home_parish
          candidate.sponsor_eligibility.sponsor_church = candidate.sponsor_covenant.sponsor_church
          candidate.sponsor_eligibility.scanned_eligibility = candidate.sponsor_covenant.sponsor_eligibility
          candidate.save(validate: false)
        end

        # change old_key back to new key_event for SponsorCovenant
        if ConfirmationEvent.all.size > 0
          ce = ConfirmationEvent.find_by(event_key: old_key)
          new_key = SponsorCovenant.event_key
          ce.event_key = new_key if ce
          ce.save if ce
          raise(RuntimeError, "Confirmation Event not found: #{old_key} (old key)") unless ce
        end

      end
      dir.down do
        # move values back to SponsorCovenant
        Candidate.all.each do |candidate|
          candidate.sponsor_covenant.sponsor_attends_home_parish = candidate.sponsor_eligibility.sponsor_attends_home_parish
          candidate.sponsor_covenant.sponsor_church = candidate.sponsor_eligibility.sponsor_church
          candidate.sponsor_covenant.scanned_eligibility = candidate.sponsor_eligibility.sponsor_eligibility
          candidate.save(validate: false)
        end
        # get rid of new CandidateEvent
        if ConfirmationEvent.all.size > 0
          if ConfirmationEvent.find_by(event_key: event_key)
            AppFactory.revert_confirmation_event(event_key)
          else
            raise(RuntimeError, "Confirmation Event not found: #{event_key} (event key)")
          end
        end
        if ConfirmationEvent.all.size > 0
          # change new_key back to old key_event
          new_key = SponsorCovenant.event_key
          ce = ConfirmationEvent.find_by(event_key: new_value)
          ce.name = old_key if ce
          ce.save if ce
          raise(RuntimeError, "Confirmation Event not found: #{new_key} (new key)") unless ce
        end
      end
    end

    remove_column :sponsor_covenants, :sponsor_attends_home_parish, :boolean
    remove_column :sponsor_covenants, :sponsor_church, :string
  end
end
