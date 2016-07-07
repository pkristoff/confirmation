class AddSignedAgreementToCandidate < ActiveRecord::Migration
  def change
    add_column :candidates, :signed_agreement, :boolean, null: false, default: false
  end
end
