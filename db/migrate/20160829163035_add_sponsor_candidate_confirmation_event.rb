class AddSponsorCandidateConfirmationEvent < ActiveRecord::Migration
  def up
    AppFactory.add_confirmation_event(I18n.t('events.sponsor_agreement'))
    add_column :candidates, :sponsor_agreement, :boolean, null: false, default: false
  end

  def down
    AppFactory.revert_confirmation_event(I18n.t('events.sponsor_agreement'))
    remove_column :candidates, :sponsor_agreement
  end
end
