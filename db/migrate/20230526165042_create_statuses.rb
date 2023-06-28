# frozen_string_literal: true

#
# Migration
#
class CreateStatuses < ActiveRecord::Migration[6.1]
  # do the migration
  #
  def change
    create_table :statuses do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
    add_reference(:candidates, :status)
    remove_column :candidates, :deferred, :boolean
    active = Status.create(name: 'Active', description: 'Currently participating')
    active.save!
    deferred = Status.create(name: 'Deferred', description: 'Deferring participation from this year')
    deferred.save!
    puts "active.id=#{active.id}"
    Candidate.all.each do |candidate|
      candidate.status_id = active.id
      candidate.save!
    end
  end
end
