# frozen_string_literal: true

describe 'export_excel_job' do
  include ViewsHelpers
  before(:each) do
    @admin = FactoryBot.create(:admin)
    candidate = create_candidate('Paul', 'Richard', 'Kristoff')
    AppFactory.add_confirmation_events
  end
  it 'should raise unknow type message' do
    export_excel_job_spec = ExportExcelJobSpec.new

    status_code = export_excel_job_spec.perform('foo', @admin).status_code
    expect(status_code.to_s.start_with?('20')).to eq(true)

    expect(export_excel_job_spec.admin).to eq(@admin)
    expect(export_excel_job_spec.message).to eq("ExportExcelJob unknown type 'foo'")
    expect(export_excel_job_spec.backtrace).to eq('ExportExcelJob#perform')
    expect(export_excel_job_spec.email_error_message_called).to eq(true)
  end
  it 'should attach file without scanned pictures' do
    export_excel_job_spec = ExportExcelJobSpec.new
    expect(export_excel_job_spec.perform(I18n.t('views.imports.excel_no_pict'), @admin).status_code.start_with?('20')).to eq(true)
    expect(export_excel_job_spec.admin).to eq(@admin)
    expect(export_excel_job_spec.dir).to eq('xlsx_export')
    expect(export_excel_job_spec.export_to_excel_no_pictures_called).to eq(true)

  end
end

class ExportExcelJobSpec < ExportExcelJob
  attr_accessor :email_error_message_called, :export_to_excel_no_pictures_called, :admin, :dir, :type, :message, :backtrace

  def initialize
    @email_error_message_called = false
    @export_to_excel_no_pictures_called = false
    @admin = nil
    @type = nil
    @message = nil
    @backtrace = nil
    @dir = nil
    super
  end

  def email_error_message(admin, message, backtrace)
    @admin = admin
    @type = type
    @message = message
    @backtrace = backtrace
    @email_error_message_called = true
    super
  end

  def export_to_excel_no_pictures(dir, admin)
    @dir = dir
    @admin = admin
    @export_to_excel_no_pictures_called = true
    super
  end
end
