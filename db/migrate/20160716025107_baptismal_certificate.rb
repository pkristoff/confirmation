class BaptismalCertificate < ActiveRecord::Migration
  def up
    AppFactory.add_confirmation_event_due_date(I18n.t('events.upload_baptismal_certificate'))
    add_column :candidates, :baptized_at_stmm, :boolean, null: false, default: true
  end

  def down
    AppFactory.revert_confirmation_event(I18n.t('events.upload_baptismal_certificate'))
    remove_column(:candidates, :baptized_at_stmm)
  end
end
