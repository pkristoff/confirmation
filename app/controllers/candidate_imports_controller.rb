# frozen_string_literal: true

#
# Handles CandidateImport tasks
#
class CandidateImportsController < ApplicationController
  include FileHelper
  before_action :authenticate_admin!

  attr_accessor :candidate_import

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
    else
      begin
        @candidate_import = CandidateImport.new
        if @candidate_import.load_initial_file(import_file_param.values.first)
          redirect_to root_url, notice: I18n.t('messages.import_successful')
        else
          render :new
        end
      rescue StandardError => e
        flash.now[:alert] = e.message
        render :new
      end
    end
  end

  # export whole database to excel.  Optionally, don't include scanned pictures
  #
  # === Attributes:
  #
  # * <tt>:commit</tt> legal values
  # ** <code>views.imports.excel_no_pict</code>
  #
  def export_to_excel
    ExportExcelJob.perform_async(params[:commit], current_admin)

    redirect_to new_candidate_import_path, notice: t('messages.export_to_excel',
                                                     email: current_admin.email,
                                                     commit: params[:commit])
  rescue StandardError => e
    redirect_to new_candidate_import_path, alert: e.message
  end

  # new candidate import
  #
  def new
    @candidate_import ||= CandidateImport.new
    nil
  end
end
