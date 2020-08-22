# frozen_string_literal: true

#
# Handles reset_database & start_new_year
#
class ResetDbController < ApplicationController
  # Reset the database.  End up with only an admin + confirmation events and the candidate vickikristoff
  #
  def reset_database
    sign_out current_admin
    ResetDB.reset_database
    redirect_to root_url, notice: I18n.t('messages.database_reset')
  end

  # Starts new school year
  #
  def start_new_year
    ResetDB.start_new_year
    redirect_to root_url, notice: I18n.t('messages.candidates_removed')
  end
end
