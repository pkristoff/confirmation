include FileHelper

class CandidateImportsController < ApplicationController

  before_action :authenticate_admin!

  attr_accessor :candidate_import

  def orphaned_table_rows
    case params[:commit]
      when t('views.imports.check_orphaned_table_rows')
        @candidate_import = CandidateImport.new.add_orphaned_table_rows
      when t('views.imports.remove_orphaned_table_rows')
        @candidate_import = CandidateImport.new.remove_orphaned_table_rows
    end
  end

  def check_events
    if params[:commit] == t('views.imports.add_missing_events')
      if params[:candidate_import][:missing] == ''
        flash[:alert] = t('views.imports.check_events_first')
      else
        @candidate_import = CandidateImport.new.add_missing_events(params[:candidate_import][:missing].split(':'))
      end
      @candidate_import = CandidateImport.new.check_events
    else
      @candidate_import = CandidateImport.new.check_events
    end
  end

  def create
    import_file_param = params[:candidate_import]
    if import_file_param.nil?
      redirect_to new_candidate_import_url, alert: I18n.t('messages.select_excel_file')
    elsif File.extname(import_file_param.values.first.original_filename) === '.zip'
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

  def export_to_excel

    dir = 'xlsx_export'

    delete_dir(dir)

    begin
      Dir.mkdir(dir)

      CandidateImport.new.to_xlsx(dir).serialize("#{dir}/export.xlsx", true)

      zip_filename = 'xlsx_export.zip'
      temp_file = Tempfile.new(zip_filename)
      Zip::OutputStream.open(temp_file) { |zos| zos }
      Zip::File.open(temp_file.path, Zip::File::CREATE) do |zip|
        # zip.add(dir, dir)
        Dir.foreach(dir) do |filename|
          zip.add(filename, File.join(dir, filename)) unless File.directory?("#{dir}/#{filename}") || filename === zip_filename
          # File.delete("#{dir}/#{filename}") unless File.directory?("#{dir}/#{filename}")
        end
      end
      zip_data = File.read(temp_file.path)
      send_data(zip_data, type:'application/zip', filename: zip_filename)

      # send_file(, type: 'application/zip', x_sendfile: true, disposition: 'attachment')
    ensure
      temp_file.close unless temp_file.nil?
      temp_file.unlink unless temp_file.nil?
      delete_dir(dir)
    end
  end

  def reset_database
    sign_out current_admin
    CandidateImport.new.reset_database
    redirect_to root_url, notice: I18n.t('messages.database_reset')
  end

  def start_new_year
    CandidateImport.new.start_new_year
    redirect_to root_url, notice: I18n.t('messages.candidates_removed')
  end

  def new
    @candidate_import = @candidate_import ? @candidate_import : CandidateImport.new
  end
end
