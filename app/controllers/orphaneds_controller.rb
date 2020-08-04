# frozen_string_literal: true

#
# Handles the showing & removal of orphaned foreign keys
#
class OrphanedsController < ApplicationController
  include OrphanedsHelper
  # check for orphaned table rows -- table rows with foreign key ids in other tables but other tables do not refernce it.
  #
  def check
    @orphaneds = Orphaneds.add_orphaned_table_rows
    @candidate_import = CandidateImport.new
    no_orphans = t('messages.orphaneds.check.no_orphans_found')
    flash[:notice] = @orphaneds.orphaned_table_rows.empty? ? no_orphans : t('messages.orphaneds.check.orphans_found')
    render new_candidate_import_path
  end

  # remove for orphaned table rows -- table rows with foriegn key ids in other tables but other tables do not refernce it.
  #
  def remove
    @orphaneds = Orphaneds.remove_orphaned_table_rows
    @candidate_import = CandidateImport.new
    no_orphans = t('messages.orphaneds.check.no_orphans_found')
    flash[:notice] = @orphaneds.orphaned_table_rows.empty? ? no_orphans : t('messages.orphaneds.check.orphans_found')
    render new_candidate_import_path
  end
end
