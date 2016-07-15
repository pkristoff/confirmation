class AddCandidateInformationSheet < ActiveRecord::Migration
  def up
    AppFactory.add_confirmation_event(I18n.t('events.fill_out_candidate_sheet'))
  end

  def down
    AppFactory.revert_confirmation_event(I18n.t('events.fill_out_candidate_sheet'))
  end
end
