class AddSignedAgreementToCandidate < ActiveRecord::Migration
  def change
    # signed_agreement - signed the confirmation agreement
    add_column :candidates, :signed_agreement, :boolean, null: false, default: false
  end
end
