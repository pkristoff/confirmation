class CreateRetreatVerifications < ActiveRecord::Migration
  def up
    #TODO: remove add
    AppFactory.add_confirmation_event(I18n.t('events.retreat_verification'))

    create_table :retreat_verifications do |t|
      t.boolean :retreat_held_at_stmm, null: false, default: false
      t.date :start_date
      t.date :end_date
      t.string :who_held_retreat
      t.string :where_held_retreat
      t.string :retreat_filename
      t.string :retreat_content_type
      t.string :retreat_file_content

      t.timestamps null: false
    end

    add_reference(:candidates, :retreat_verification, index: true, foreign_key: true)

    Candidate.all.each do |candidate|
      candidate.build_retreat_verification
      result = candidate.save(validate: false)
      puts "Adding retreat_verification to #{candidate.account_name} candidate=#{candidate}retreat_verification=#{candidate.retreat_verification} save passed=#{result}"
    end
  end


  def down

    Candidate.all.each do |candidate|
      puts "removing retreat_verification to #{candidate.account_name}"
      candidate.retreat_verification = nil
      candidate.save(validate: false)
    end

    remove_foreign_key(:candidates, :retreat_verifications)
    remove_reference(:candidates, :retreat_verification)
    drop_table(:retreat_verifications)
  end
end
