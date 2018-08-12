# frozen_string_literal: true

#
# Handles CandidateImport tasks
#
class CandidateImportsController < ApplicationController
  include FileHelper
  before_action :authenticate_admin!

  attr_accessor :candidate_import

  # find orphaned table rows -- table rows with foriegn key ids in other tables but other tables do not refernce it.
  #
  # === Attributes:
  #
  # * <tt>:commit</tt> legal values
  # ** <code>views.imports.check_orphaned_table_rows</code>  show info on orphaned rows
  # ** <code>views.imports.remove_orphaned_table_rows</code> remove orphaned rows
  # *** <code>:missing</code> list of missing events
  #
  def orphaned_table_rows
    case params[:commit]
    when t('views.imports.check_orphaned_table_rows')
      @candidate_import = CandidateImport.new.add_orphaned_table_rows
    when t('views.imports.remove_orphaned_table_rows')
      @candidate_import = CandidateImport.new.remove_orphaned_table_rows
    end
  end

  # Checks for missing ConfirmationEvents if :missing is supplied then update system with missing
  # ConfirmationEvents.
  #
  # === Attributes:
  #
  # * <tt>:commit</tt> legal values
  # ** <code>views.imports.check_events</code>  Check to see if all ConfirmationEvents are present
  # ** <code>views.imports.add_missing_events</code> legal values
  # *** <code>:missing</code> list of missing events
  #
  def check_events
    if params[:commit] == t('views.imports.add_missing_events')
      if params[:candidate_import][:missing] == ''
        flash[:alert] = t('views.imports.check_events_first')
      else
        @candidate_import = CandidateImport.new.add_missing_events(params[:candidate_import][:missing].split(':'))
      end
    end
    @candidate_import ||= CandidateImport.new.check_events
    nil
  end

  # load in an zip file which is an excel spreadsheet with pictures or an initial file which is the initial
  # import of candidates
  #
  # === Attributes:
  #
  # * <tt>:candidate_import</tt> the file being uploaded
  #
  def import_candidates
    import_file_param = params[:candidate_import]
    if import_file_param.nil?
      redirect_to new_candidate_import_url, alert: I18n.t('messages.select_excel_file')
    elsif File.extname(import_file_param.values.first.original_filename) == '.zip'
      @candidate_import = CandidateImport.new(uploaded_zip_file: import_file_param.values.first)
      if @candidate_import.load_zip_file(import_file_param.values.first)
        redirect_to root_url, notice: I18n.t('messages.import_successful')
      else
        render :new
      end
    else
      @candidate_import = CandidateImport.new
      if @candidate_import.load_initial_file(import_file_param.values.first)
        redirect_to root_url, notice: I18n.t('messages.import_successful')
      else
        render :new
      end
    end
  end

  # export whole database to excel.  Optionally, don't include scanned pictures
  #
  # === Attributes:
  #
  # * <tt>:commit</tt> legal values
  # ** <code>views.imports.excel</code>
  # ** <code>views.imports.excel_no_pict</code>
  #
  def export_to_excel
    ExportExcelJob.perform_async(params[:commit], current_admin)

    redirect_to new_candidate_import_path, notice: t('messages.export_to_excel', commit: params[:commit])
  rescue StandardError => e
    redirect_to new_candidate_import_path, alert: e.message
  end

  # Reset the database.  End up with only an admin + confirmation events and the candidate vickikristoff
  #
  def reset_database
    sign_out current_admin
    CandidateImport.new.reset_database
    redirect_to root_url, notice: I18n.t('messages.database_reset')
  end

  # Starts new school year
  #
  def start_new_year
    CandidateImport.new.start_new_year
    redirect_to root_url, notice: I18n.t('messages.candidates_removed')
  end

  # new candidate import
  #
  def new
    @candidate_import ||= CandidateImport.new
    nil
  end
end
