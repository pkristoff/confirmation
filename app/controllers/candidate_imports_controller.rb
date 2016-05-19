class CandidateImportsController < ApplicationController

  before_action :authenticate_admin!

  attr_accessor :candidate_import

  def create
    import_file_param = params[:candidate_import]
    if import_file_param.nil?
      redirect_to new_candidate_import_url, alert: 'Please select a excel file to upload.'
    else
      @candidate_import = CandidateImport.new(uploaded_file: import_file_param.values.first)
      if @candidate_import.save
        redirect_to root_url, notice: "Imported candidates successfully."
      else
        render :new
      end
    end
  end

  def reset_database
    sign_out current_admin
    CandidateImport.new.reset_database
    redirect_to root_url, notice: "Database successfully reset."
  end

  def remove_all_candidates
    CandidateImport.new.remove_all_candidates
    redirect_to root_url, notice: "All candidates successfully removed."
  end

  def new
    @candidate_import = CandidateImport.new
  end
end
