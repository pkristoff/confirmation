# frozen_string_literal: true

#
# Migration
#
class CreateStatuses < ActiveRecord::Migration[6.1]
  # do the migration
  #
  def change
    # drop_table :statuses if ActiveRecord::Base.connection.table_exists?(:statuses)
    create_table :statuses do |t|
      t.string :name
      t.text :description
      t.timestamps
    end
    # create default Statuses
    return unless Status.find_by(name: Status::ACTIVE).nil?

    active = Status.create(name: Status::ACTIVE, description: 'Currently participating')
    active.save!
    deferred = Status.create(name: Status::DEFERRED, description: 'Deferring participation from this year')
    deferred.save!

  end
end
