class CandidateImportsController < ApplicationController

  before_action :authenticate_admin!

  attr_accessor :candidate_import

  def create
    import_file_param = params[:candidate_import]
    if import_file_param.nil?
      redirect_to new_candidate_import_url, alert: I18n.t('messages.select_excel_file')
    else
      @candidate_import = CandidateImport.new(uploaded_file: import_file_param.values.first)
      if @candidate_import.save
        redirect_to root_url, notice: I18n.t('messages.import_successful')
      else
        render :new
      end
    end
  end

  def export_to_excel

    respond_to do |format|
      format.xlsx { send_data(CandidateImport.new.to_xlsx().read, disposition: 'attachment; filename=aaa_stream_2.xlsx') }
    end

  end

  def reset_database
    sign_out current_admin
    CandidateImport.new.reset_database
    redirect_to root_url, notice: I18n.t('messages.database_reset')
  end

  def remove_all_candidates
    CandidateImport.new.remove_all_candidates
    redirect_to root_url, notice: I18n.t('messages.candidates_removed')
  end

  def new
    @candidate_import = CandidateImport.new
  end
end
