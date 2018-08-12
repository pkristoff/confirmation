# frozen_string_literal: true

# Handle putting the exporting of the database to a seperate process with result being mailed tot the admin.
#
class ExportExcelJob
  include FileHelper
  include SuckerPunch::Job

  # called with perform_async
  #
  # === Parameters:
  #
  # * <tt>:type</tt> type of export to excel with or without pictures
  # ** <code>:views.imports.excel</code> export to excel with scanned pitcture
  # ** <code>:views.imports.excel_no_pict</code>  export to excel withOUT scanned pitcture
  # * <tt>:admin</tt> who to send the spreadsheet to
  #
  def perform(type, admin)
    dir = 'xlsx_export'
    delete_dir(dir)

    case type
    when I18n.t('views.imports.excel')
      export_to_excel_pictures(dir, admin)
    when I18n.t('views.imports.excel_no_pict')
      # No need to create & delete dir
      export_to_excel_no_pictures(dir, admin)
    else
      email_error_message(admin, "ExportExcelJob unknown type '#{type}'", 'ExportExcelJob#perform')
    end
  end

  # send excel spreadsheet to admin of the database without scanned in pictures
  #
  # === Parameters:
  #
  # * <tt>:dir</tt> temp directory for location of attach file
  # * <tt>:admin</tt> receiver of email messae
  #
  # === Returns:
  #
  # * <tt>Number</tt> response code from sending an email.
  #
  def export_to_excel_no_pictures(dir, admin)
    response = nil
    path = "#{dir}/export_no_pictures.xlsx"
    begin
      Dir.mkdir(dir)
      CandidateImport.new.to_xlsx(dir, false).serialize(path, true)
      Rails.logger.info("export_to_excel_no_pictures - serialize=#{path}")
      response = SendGridMail.new(admin, []).export_to_excel_no_pictures_message(path)
    ensure
      delete_dir(dir)
    end
    Rails.logger.info("export_to_excel_no_pictures - response=#{response}")
    response
  end

  # send excel spreadsheet to admin of the database with scanned in pictures
  #
  # === Parameters:
  #
  # * <tt>:dir</tt> temp directory for location of attach file
  # * <tt>:admin</tt> receiver of email messae
  #
  # === Returns:
  #
  # * <tt>Number</tt> response code from sending an email.
  #
  def export_to_excel_pictures(dir, admin)
    response = nil
    begin
      Dir.mkdir(dir)

      file_path, temp_file = generate_zip(dir)
      Rails.logger.info("export_to_excel_pictures - temp_file.path=#{temp_file.path}")
      Rails.logger.info("export_to_excel_pictures - file_path=#{file_path}")
      # Rails.logger.info("export_to_excel_pictures - temp_file.original_filename=#{temp_file.public_methods.sort}")
      response = SendGridMail.new(admin, []).export_to_excel_pictures_message(file_path)
    ensure
      temp_file&.close
      temp_file&.unlink
      delete_dir(dir)
    end
    Rails.logger.info("export_to_excel_pictures - response#{response}")
    response
  end

  # generate the zip file for exporting to excel with pictures
  # TEST - ONLY
  #
  # === Parameters:
  #
  # * <tt>:dir</tt> temp directory for location of attach file
  #
  # === Returns:
  #
  # * <tt>String</tt> file_path of the zip file
  #
  def generate_zip(dir)
    CandidateImport.new.to_xlsx(dir).serialize("#{dir}/export.xlsx", true)
    zip_filename = "#{dir}/xlsx_export"
    temp_file = Tempfile.new(zip_filename)
    file_path = "#{zip_filename}.zip"
    Zip::OutputStream.open(temp_file) { |zos| zos }
    Zip::File.open(temp_file.path, Zip::File::CREATE) do |zip|
      Dir.foreach(dir) do |filename|
        zip.add(filename, File.join(dir, filename)) unless File.directory?("#{dir}/#{filename}") || filename == zip_filename
      end
    end
    FileUtils.move(temp_file.path, file_path)
    [file_path, temp_file]
  end

  protected

  def email_error_message(admin, message, backtrace)
    SendGridMail.new(admin, []).email_error_message(message, backtrace)
  end
end
