class AddAttendRetreat < ActiveRecord::Migration
  def up
    AppFactory.add_confirmation_event_due_date(I18n.t('events.retreat_verification'))
  end

  def down
    AppFactory.revert_confirmation_event(I18n.t('events.retreat_verification'))
  end
end
