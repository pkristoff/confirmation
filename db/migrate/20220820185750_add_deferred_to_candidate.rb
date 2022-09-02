class AddDeferredToCandidate < ActiveRecord::Migration[6.1]
  def change
    add_column :candidates, :deferred, :boolean, null: false, default: false
  end
end
