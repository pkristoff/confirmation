class CandidateImportsController < ApplicationController

  before_action :authenticate_admin!

  attr_accessor :candidate_import

  def create
    @candidate_import = CandidateImport.new(uploaded_file: params[:candidate_import].values.first)
    if @candidate_import.save
      redirect_to root_url, notice: "Imported candidates successfully."
    else
      render :new
    end
  end

  def reset
    sign_out current_user
    CandidateImport.reset
  end

  def new
    @candidate_import = CandidateImport.new
  end
end
