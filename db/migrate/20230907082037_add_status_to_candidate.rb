# Add reference to new Status to Candidate plus
# remove the deferred column plus
# update all candidates to refer to Active status
#
class AddStatusToCandidate < ActiveRecord::Migration[6.1]
  # do change
  #
  def change
    # unless ActiveRecord::Base.connection.column_exists?(:candidates, :deferred)
    #   add_column :candidates, :deferred, :boolean :default true
    #   remove_reference(:candidates, :status)
    # end
    add_reference(:candidates, :status)
    remove_column :candidates, :deferred, :boolean
    active = Status.active
    Candidate.all.each do |candidate|
      candidate.status_id = active.id
      candidate.save!
    end
  end
end
