class RemoveSponsorAgreementFromCandidates < ActiveRecord::Migration[5.2]
  def change
    conversations = ConfirmationEvent.select { |conf_event| conf_event.name == 'Sponsor and Candidate Conversation' }
    conversations.each &:destroy
    remove_column :candidates, :sponsor_agreement, :boolean
  end
end
