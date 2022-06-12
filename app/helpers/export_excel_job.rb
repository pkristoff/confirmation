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
  # ** <code>:views.imports.excel_no_pict</code>  export to excel withOUT scanned pitcture
  # * <tt>:admin</tt> who to send the spreadsheet to
  #
  def perform(type, admin)
    dir = 'xlsx_export'
    delete_dir(dir)

    case type
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
      CandidateImport.new.to_xlsx(dir).serialize(path, confirm_valid: true)
      Rails.logger.info("export_to_excel_no_pictures - serialize=#{path}")
      response = SendGridMail.new(admin, []).export_to_excel_no_pictures_message(path)
    ensure
      delete_dir(dir)
    end
    Rails.logger.info("export_to_excel_no_pictures - SendGridMail-response=#{response}")
    Rails.logger.info("export_to_excel_no_pictures - SendGridMail-response=#{response.status_code}")
    Rails.logger.info("export_to_excel_no_pictures - SendGridMail-response=#{response.body}")
    Rails.logger.info("export_to_excel_no_pictures - SendGridMail-response=#{response.public_methods}")
    response
  end

  protected

  def email_error_message(admin, message, backtrace)
    SendGridMail.new(admin, []).email_error_message(message, backtrace)
  end
end
