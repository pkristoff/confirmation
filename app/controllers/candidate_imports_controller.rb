class CandidateImportsController < ApplicationController

  before_action :authenticate_admin!

  attr_accessor :candidate_import

  def new
    @candidate_import = CandidateImport.new
  end

  def create
    @candidate_import = CandidateImport.new(uploaded_file: params[:candidate_import].values.first)
    if @candidate_import.save
      redirect_to root_url, notice: "Imported candidates successfully."
    else
      render :new
    end
  end
end
