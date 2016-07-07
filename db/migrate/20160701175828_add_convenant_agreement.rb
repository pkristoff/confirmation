class AddConvenantAgreement < ActiveRecord::Migration
  def up
    AppFactory.add_confirmation_event(I18n.t('events.sign_convenant_agreement'))
  end

  def down
    AppFactory.revert_confirmation_event(I18n.t('events.sign_convenant_agreement'))
  end
end
