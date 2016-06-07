class AddAttendRetreat < ActiveRecord::Migration
  def up
    AppFactory.add_confirmation_event(I18n.t('events.retreat_weekend'))
  end

  def down
    AppFactory.revert_confirmation_event(I18n.t('events.retreat_weekend'))
  end
end
