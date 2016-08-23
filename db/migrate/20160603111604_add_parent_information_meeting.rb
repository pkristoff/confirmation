class AddParentInformationMeeting < ActiveRecord::Migration
  def up
    AppFactory.add_confirmation_event_due_date(I18n.t('events.parent_meeting'))
  end

  def down
    AppFactory.revert_confirmation_event(I18n.t('events.parent_meeting'))
  end
end
