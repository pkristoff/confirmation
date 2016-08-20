class AddConfirmationName < ActiveRecord::Migration
  def up
    AppFactory.add_confirmation_event(I18n.t('events.confirmation_name'))
  end

  def down
    AppFactory.revert_confirmation_event(I18n.t('events.confirmation_name'))
  end
end
