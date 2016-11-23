class AddCovenantAgreement < ActiveRecord::Migration
  def up
    AppFactory.add_confirmation_event_due_date(I18n.t('events.candidate_covenant_agreement'))
  end

  def down
    AppFactory.revert_confirmation_event(I18n.t('events.candidate_covenant_agreement'))
  end
end
