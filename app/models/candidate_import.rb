# frozen_string_literal: true

#
# A helper class used for importing and exporting the DB information.
#
class CandidateImport
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  include FileHelper

  attr_accessor :uploaded_file, :uploaded_zip_file, :imported_candidates

  EXTRACTED_ZIP_DIR = 'temp'

  # Returns Array of image columns
  #
  # === Returns:
  #
  # * <tt>Array</tt> of image columns
  #
  def self.image_columns
    %w[
      baptismal_certificate.scanned_certificate
      retreat_verification.scanned_retreat
      sponsor_covenant.scanned_covenant
      sponsor_eligibility.scanned_eligibility
    ]
  end

  # Returns Array of transient columns
  #
  # === Returns:
  #
  # * <tt>Array</tt> of transient columns
  #
  def self.transient_columns
    %w[
      baptismal_certificate.certificate_picture
      baptismal_certificate.remove_certificate_picture
      retreat_verification.retreat_verification_picture
      retreat_verification.remove_retreat_verification_picture
      sponsor_covenant.sponsor_eligibility_picture
      sponsor_covenant.sponsor_covenant_picture
      sponsor_covenant.remove_sponsor_eligibility_picture
      sponsor_covenant.remove_sponsor_covenant_picture
    ]
  end

  # initialize new instance
  #
  # === Parameters:
  #
  # * <tt>:attributes</tt> name value pairs
  #
  # === Returns:
  #
  # * <tt>Hash</tt> of information to be verified
  #
  def initialize(attributes = {})
    attributes.each { |name, value| send("#{name}=", value) }
    @worksheet_conf_event_name = 'Confirmation Events'
    @worksheet_name = 'Candidates with events'
  end

  # filepath for exporting
  #
  # === Parameters:
  #
  # * <tt>:candidate</tt> Candidate: being exported
  # * <tt>:dir</tt> String: the directory
  # * <tt>:image_column</tt> Symbol: The ScannedImage accessor.
  # * <tt>:image</tt> ScannedImage: the image being exported
  #
  # === Returns:
  #
  # * <tt>String</tt> the file path
  #
  def self.image_filepath_export(candidate, dir, image_column, image)
    file_basename = image.nil? ? '' : File.basename(image.filename)
    "#{dir}/#{candidate.account_name}_#{image_column}_#{file_basename}"
  end

  # File for importing
  #
  # === Parameters:
  #
  # * <tt>:file_path</tt> String: filepath for importing
  #
  # === Returns:
  #
  # * <tt>File</tt> for file_path
  #
  def self.image_filename_import(file_path)
    File.basename(file_path)
  end

  # Load an excel file with initial list of candidates.  It can be loaded in multiple times
  #
  # === Parameters:
  #
  # * <tt>:file</tt> String: filepath
  #
  # === Returns:
  #
  # * <tt>Boolean</tt> whether valid
  #
  def load_initial_file(file)
    @uploaded_file = file
    @imported_candidates = load_imported_candidates
    validate_and_save_import
  end

  # needed to expand _candidate_import.html.erb
  #
  # === Returns:
  #
  # * <tt>Boolean</tt> false
  #
  def persisted?
    false
  end

  # exporting the DB tables to excel.
  #
  # === Parameters:
  #
  # * <tt>:dir</tt> String:  where to store the zip file.
  # * <tt>:from_spec</tt> Boolean:  whether this is from a spec test or production.
  #
  # === Returns:
  #
  # * <tt>Package</tt> package
  #
  def to_xlsx(dir, from_spec: false)
    p = create_xlsx_package(dir, from_spec: from_spec)
    # the Package will be generated with a shared string table
    p.use_shared_strings = true
    p
  end

  # test only
  # gets columns
  #
  # === Returns:
  #
  # * <tt>CandidateImport</tt> self
  #
  def xlsx_columns
    params = Candidate.permitted_params
    columns = []
    get_columns(params, columns)
    columns.delete(:password)
    columns.delete(:password_confirmation)
    ['baptismal_certificate.scanned_certificate', 'baptismal_certificate.scanned_prof', 'retreat_verification.scanned_retreat',
     'sponsor_covenant.scanned_covenant', 'sponsor_eligibility.scanned_eligibility'].each do |base|
      ScannedImage.permitted_params.each do |not_exported|
        columns.delete("#{base}.#{not_exported}")
      end
    end
    (0..confirmation_events_sorted.length - 1).each do |index|
      columns << "candidate_events.#{index}.completed_date"
      columns << "candidate_events.#{index}.verified"
    end
    columns
  end

  # test only
  # Conifirmation Event columns
  #
  # === Returns:
  #
  # * <tt>Array</tt> String
  #
  def xlsx_conf_event_columns
    %w[event_key index program_year1_due_date program_year2_due_date instructions]
  end

  private

  # Get a candidate's CandidateEvent in order
  #
  # === Parameters:
  #
  # * <tt>:candidate</tt> Candidate:
  #
  # === Returns:
  #
  # * <tt>Array</tt> of CandidateEvent
  #
  def candidate_events_in_order(candidate)
    events = []
    @events_in_order.each do |confirmation_event|
      events << candidate.get_candidate_event(confirmation_event.event_key)
    end
    events
  end

  def content_type(type)
    return type if type.blank?

    type.split('/')[1]
  end

  # adds ConfirmationEvents to a worksheet in the workbook
  #
  # === Parameters:
  #
  # * <tt>:wb</tt> Workbook: excel workbook.
  #
  def create_confirmation_event(wbk)
    confirmation_event_columns = xlsx_conf_event_columns
    wbk.add_worksheet(name: @worksheet_conf_event_name) do |sheet|
      sheet.add_row confirmation_event_columns
      confirmation_events_sorted.each_with_index do |confirmation_event, index|
        sheet.add_row(confirmation_event_columns.map do |col|
          if col == 'index'
            index
          else
            confirmation_event.send(col)
          end
        end)
      end
    end
  end

  # create and fill in an Axlsx::Package
  #
  # === Parameters:
  #
  # * <tt>:dir</tt> String: base filepath
  #
  # === Returns:
  #
  # Axlsx::Package:
  #
  def create_xlsx_package(dir, from_spec: false)
    # http://www.rubydoc.info/github/randym/axlsx/Axlsx/Workbook:use_shared_strings
    p = Axlsx::Package.new(author: 'Admin')
    wb = p.workbook
    create_confirmation_event(wb)

    the_candidate_columns = xlsx_columns
    wb.add_worksheet(name: @worksheet_name) do |sheet|
      sheet.add_row the_candidate_columns
      candidate_order = Candidate.order(:account_name)
      expected_rows = candidate_order.size + 1
      candidate_order.each do |candidate|
        ExportExcelCandJob.new.perform(candidate.id, sheet, the_candidate_columns, dir) if from_spec
        ExportExcelCandJob.perform_async(candidate.id, sheet, the_candidate_columns, dir) unless from_spec
      end
      sleep(2) while !from_spec && jobs_left(expected_rows, sheet.rows.size)
    end
    p
  end

  def jobs_left(expectd_rows, current_row_size)
    all_stats = SuckerPunch::Queue.stats
    stats = all_stats[ExportExcelCandJob.to_s]
    current_row_size + stats['jobs']['failed'] < expectd_rows
  end

  # get value to put in cell
  #
  # === Parameters:
  #
  # * <tt>:candidate</tt> Candidate:
  # * <tt>:col</tt> String:
  # * <tt>:confirmation_events</tt> Array:
  #
  # === Returns:
  #
  # Object: self
  #
  def get_column_value(candidate, col, confirmation_events)
    split = col.split('.')
    case split.size
    when 1
      candidate.send(col)
    when 2
      candidate_send0 = candidate.send(split[0])
      if candidate_send0.nil?
        nil
      else
        candidate_send0.send(split[1])
      end
    when 3
      if split[0] != 'candidate_events'
        candidate_send0 = candidate.send(split[0])
        if candidate_send0.nil?
          nil
        else
          candidate_send0.send(split[1]).send(split[2])
        end
      else
        confirmation_event = confirmation_events[split[1].to_i]
        cand_event = candidate.get_candidate_event(confirmation_event.event_key)
        cand_event.send(split[2])
      end
    else
      "Unexpected split size: #{split.size}"
    end
  end

  #
  #
  # === Parameters:
  #
  # * <tt>:params</tt> Array:
  # * <tt>:columns</tt> Array: column names
  # * <tt>:_prefix_</tt> String:  optional prefix to add to columns
  #
  def get_columns(params, columns, prefix = '')
    return columns if params.empty?

    params.each do |param|
      if param.is_a?(Hash)
        param.each_key do |key|
          next if key == :candidate_events_attributes

          key_str = key.to_s
          xxx = key_str[0, key_str.size - 11] # 11 = ('_attributes'.size)
          get_columns(param[key], columns, (prefix.empty? ? xxx : "#{prefix}.#{xxx}"))
        end
      else
        # no need to save id because it will get a new id when filed in.
        parameter = prefix.empty? ? param.to_s : "#{prefix}.#{param}"
        columns << parameter unless param == :id || CandidateImport.transient_columns.include?(parameter)
      end
    end
  end

  # return sorted array of ConfirmationEvent by name
  #
  # === Returns:
  #
  # Array: ConfirmationEvent
  #
  def confirmation_events_sorted
    ConfirmationEvent.order(:event_key)
  end

  # process uploaded file
  #   uploaded_file:  an xlsx file with some initial candidate information
  #   uploaded_zip_file:  created by exporting the DB tables
  #
  def load_imported_candidates
    # uploaded_file is an xlsx, either initial file or an exported file.
    return unless uploaded_file

    candidates = []
    @candidate_to_row = {}
    spreadsheet = open_spreadsheet
    if spreadsheet.sheets[0] == @worksheet_name || spreadsheet.sheets[0] == @worksheet_conf_event_name
      process_exported_xlsx(candidates, spreadsheet)
    else
      process_initial_xlsx(candidates, spreadsheet)
    end
    spreadsheet.close
    candidates
  end

  # read in spreadsheet from given file.
  #
  # === Returns:
  #
  # Roo::Excelx:
  #
  def open_spreadsheet
    is_zip = !uploaded_file.respond_to?(:original_filename)
    path = is_zip ? uploaded_file : uploaded_file.path
    case File.extname(is_zip ? File.basename(uploaded_file) : uploaded_file.original_filename)
    when '.xlsx'
      spreadsheet = Roo::Excelx.new(path, file_warning: :ignore)
      spreadsheet.header_line = 1
      spreadsheet.default_sheet = spreadsheet.sheets[0]
      spreadsheet
      # Axlsx::Workbook.new(path)
    else
      raise "Unknown file type: #{uploaded_file.original_filename}"
    end
  end

  # process/create Candidates based on spreadsheet and add to candidates
  #
  # === Parameters:
  #
  # * <tt>:candidates</tt> Array: Candidate created
  # * <tt>:spreadsheet</tt> Roo::Excelx: read in.
  #
  def process_candidates(candidates, spreadsheet)
    sheet = spreadsheet.sheet(@worksheet_name)
    header_row = sheet.row(1)
    account_name_index = header_row.find_index { |cell| cell == 'account_name' }
    (2..spreadsheet.last_row).each do |i|
      row = sheet.row(i)

      candidate = Candidate.find_by(account_name: row[account_name_index]) || AppFactory.create_candidate
      events = candidate_events_in_order(candidate)
      row.each_with_index do |cell, index|
        column_name_split = header_row[index].split('.')
        unless cell.nil?
          if column_name_split.size == 1
            candidate.send("#{column_name_split[0]}=", cell)

          elsif column_name_split.size == 2
            case column_name_split[1]

            when 'scanned_certificate'
              candidate.baptismal_certificate.scanned_certificate = create_scanned_image(cell)
            when 'scanned_retreat'
              candidate.retreat_verification.scanned_retreat = create_scanned_image(cell)
            when 'scanned_covenant'
              candidate.sponsor_covenant.scanned_covenant = create_scanned_image(cell)
            when 'scanned_eligibility'
              candidate.sponsor_eligibility.scanned_eligibility = create_scanned_image(cell)
            else
              fff = column_name_split[1] == 'church_address' && candidate.baptismal_certificate.church_address.nil?
              candidate.baptismal_certificate.create_church_address if fff
              candidate_send0 = candidate.send(column_name_split[0])
              candidate_send0.send("#{column_name_split[1]}=", cell)
            end

          elsif column_name_split.size == 3 && column_name_split[0] != 'candidate_events'
            fff = column_name_split[1] == 'church_address' && candidate.baptismal_certificate.church_address.nil?
            candidate.baptismal_certificate.create_church_address if fff
            candidate_send0 = candidate.send(column_name_split[0])
            if candidate_send0.nil?
              nil
            else
              candidate_send__send = candidate_send0.send(column_name_split[1])
              candidate_send__send.send("#{column_name_split[2]}=", cell)
            end
          elsif column_name_split.size == 3
            events[column_name_split[1].to_i].send("#{column_name_split[2]}=", cell)
          end
        end
      end
      candidate.password = Event::Other::INITIAL_PASSWORD
      candidates.push(candidate)
    end
  end

  # create ScannedImage from cell
  #
  # === Parameters:
  #
  # * <tt>:cell</tt> String:  cell value
  #
  # === Returns:
  #
  # ScannedImage:
  #
  def create_scanned_image(cell)
    image_filename, image_content_type, export_filename = cell.split(':::')
    scanned_image = ScannedImage.new
    scanned_image.filename = image_filename
    scanned_image.content_type = "image/#{image_content_type}"
    p = "#{EXTRACTED_ZIP_DIR}/#{export_filename}"
    File.open(p, 'rb') do |f|
      scanned_image.content = f.read
    end
    scanned_image
  end

  # Create ConfirmationEvents and add to @events_in_order
  #
  # === Parameters:
  #
  # * <tt>:spreadsheet</tt> Roo::Excelx
  #
  def process_confirmation_events(spreadsheet)
    @events_in_order = []
    sheet = spreadsheet.sheet(@worksheet_conf_event_name)
    header_row = sheet.row(1)
    name_index = header_row.find_index { |cell| cell == 'name' }
    (2..spreadsheet.last_row).each do |i|
      row = sheet.row(i)
      confirmation_event = ConfirmationEvent.find_by(name: row[name_index]) || AppFactory.add_confirmation_event(row[name_index])
      row.each_with_index do |cell, index|
        column_name_split = header_row[index].split('.')
        next if cell.nil?
        next if column_name_split[0] == 'index'

        confirmation_event.send("#{column_name_split[0]}=", cell)
      end
      confirmation_event.save
      @events_in_order << confirmation_event
    end
  end

  # process spreadsheet & update candidates
  #
  # === Parameters:
  #
  # * <tt>:candidates</tt> Array: of Candidate created.
  # * <tt>:spreadsheet</tt> Roo::Excelx
  #
  def process_exported_xlsx(candidates, spreadsheet)
    process_confirmation_events(spreadsheet)

    process_candidates(candidates, spreadsheet)
  end

  # export ScannedImages
  #
  # === Parameters:
  #
  # * <tt>:images</tt> Array: ScannedImages to export
  #
  # === Returns:
  #
  # CandidateImport: self
  #
  def write_export_images(images)
    images.each do |entry|
      export_filename = entry[:export_filename]
      image = entry[:image]
      begin
        File.binwrite(export_filename, image.content)
      rescue StandardError => e
        Rails.logger.info "Exception opening file for image: #{export_filename}"
        Rails.logger.info "Error message #{e.message}"
        Rails.logger.info e.backtrace.inspect
      end
    end
  end

  # Create Candidate with some initial information
  #
  # === Parameters:
  #
  # * <tt>:candidates</tt> Array: updated with created Candidate
  # * <tt>:spreadsheet</tt> Roo::Excelx
  #
  # === Returns:
  #
  # Array: candidates
  #
  def process_initial_xlsx(candidates, spreadsheet)
    legal_headers = ['Last Name', 'First Name', 'Grade', 'Teen Email', 'Parent Email Address(es)',
                     'Attending', 'Program Year', 'Status']
    header_row = spreadsheet.first
    if header_row[0].strip.casecmp?(legal_headers[0]) &&
       header_row[1].strip.casecmp?(legal_headers[1]) &&
       header_row[2].strip.casecmp?(legal_headers[2]) &&
       header_row[3].strip.casecmp?(legal_headers[3]) &&
       header_row[4].strip.casecmp?(legal_headers[4]) &&
       header_row[5].strip.casecmp?(legal_headers[5]) &&
       header_row[6].strip.casecmp?(legal_headers[6]) &&
       header_row[7].strip.casecmp?(legal_headers[7])
      (2..spreadsheet.last_row).each do |i|
        spreadsheet_row = spreadsheet.row(i)
        # skip empty row
        next if spreadsheet_row[0].nil? && spreadsheet_row[1].nil? && spreadsheet_row[2].nil? && spreadsheet_row[3].nil?

        last_name = spreadsheet_row[0].nil? ? '' : spreadsheet_row[0].strip
        first_name = spreadsheet_row[1].nil? ? '' : spreadsheet_row[1].strip

        candidate_email = spreadsheet_row[3].nil? ? '' : spreadsheet_row[3].strip
        parent_email = spreadsheet_row[4].nil? ? '' : spreadsheet_row[4].strip

        candidate_sheet_params = ActionController::Parameters.new
        params = ActionController::Parameters.new(
          candidate: ActionController::Parameters.new(candidate_sheet_attributes: candidate_sheet_params)
        )

        # last_name
        candidate_sheet_params[:last_name] = import_last_name(last_name)

        # first_name
        candidate_sheet_params[:first_name] = import_first_name(first_name)

        # account_name
        account_name = Candidate.generate_account_name(candidate_sheet_params[:last_name].gsub(/\s+/, '') || '',
                                                       candidate_sheet_params[:first_name].gsub(/\s+/, '') || '')

        # program_year
        candidate_sheet_params[:program_year] = import_program_year(spreadsheet_row, account_name)

        # grade
        candidate_sheet_params[:grade] = import_grade(spreadsheet_row, account_name)

        # email
        clean_item = ActionView::Base.full_sanitizer.sanitize(candidate_email)

        candidate_sheet_params[:candidate_email] = clean_item unless clean_item.empty?

        clean_item = ActionView::Base.full_sanitizer.sanitize(parent_email)
        unless clean_item.empty?
          item_split = clean_item.split(',')
          candidate_sheet_params[:parent_email_1] = item_split[0].strip
          candidate_sheet_params[:parent_email_2] = item_split[1].strip if item_split.size > 1
        end

        # attending
        candidate_sheet_params[:attending] = import_attending(spreadsheet_row, account_name)

        # account_name
        params[:candidate][:account_name] = account_name

        # password
        params[:candidate][:password] = Event::Other::INITIAL_PASSWORD

        # status
        params[:candidate][:status_id] = import_status(spreadsheet_row, account_name)

        candidate = Candidate.find_by(account_name: account_name) || ::AppFactory.create_candidate

        # middle_name
        middle_name = candidate.candidate_sheet.middle_name

        permitted_params = Candidate.import_candidate_permitted_params

        candidate.update(params.require(:candidate).permit(permitted_params))

        # handle blanking of middle_name
        #
        candidate.candidate_sheet.middle_name = middle_name if middle_name.present?
        candidate.candidate_sheet.save! if middle_name.present?

        candidates.push(candidate)
        @candidate_to_row[candidate] = i
      end
      candidates
    else
      raise "Unknown spread sheet column: #{header_row} expected in order: #{legal_headers}"
    end
  end

  def import_last_name(last_name)
    name = last_name.nil? ? '' : last_name.strip
    raise 'Validation failed: Last name can\'t be blank' if name.blank?

    name.presence
  end

  def import_first_name(first_name)
    name = first_name.nil? ? '' : first_name.strip
    raise 'Validation failed: First_name can\'t be blank' if name.blank?

    name.presence
  end

  def import_status(spreadsheet_row, account_name)
    status_name = spreadsheet_row[7].nil? ? '' : spreadsheet_row[7].strip

    raise "#{account_name} Status cannot be blank." if status_name.blank?

    status = Status.find_by(name: status_name)

    raise "#{account_name} Illegal status: #{status_name}" if status.nil?

    status.id
  end

  def import_attending(spreadsheet_row, account_name)
    attending = spreadsheet_row[5].nil? ? '' : spreadsheet_row[5].strip

    attending_way = I18n.t('views.candidates.attending_the_way')
    attending_chs = I18n.t('model.candidate.abbreviated')

    raise "#{account_name} Attending cell cannot be empty" if attending.empty?

    foo = I18n.t('model.candidate.attending_the_way') if attending.strip.casecmp?(attending_way)
    foo = I18n.t('model.candidate.attending_catholic_high_school') if attending.strip.casecmp?(attending_chs)
    raise "#{account_name} Illegal Attending value: #{attending}" if foo.nil?

    foo
  end

  def import_grade(spreadsheet_row, account_name)
    grade = if spreadsheet_row[2].instance_of?(::Integer)
              (spreadsheet_row[2].nil? ? '' : "#{spreadsheet_row[2]}th")
            else
              (spreadsheet_row[2].nil? ? '' : spreadsheet_row[2].strip)
            end
    digi_grade = ''
    digi_grade = grade.slice(/^\D*\d*/) unless grade.empty?
    raise "#{account_name}: Grade should be between 9 & 12" if digi_grade.empty?

    if digi_grade.instance_of?(::String) && %w[9 10 11 12].exclude?(digi_grade)
      raise "#{account_name} Illegal grade=#{digi_grade}.  It should be between 9 & 12"
    end

    digi_grade
  end

  def import_program_year(spreadsheet_row, account_name)
    program_year = (spreadsheet_row[6].presence || '')

    raise "#{account_name} program year cannot blank" unless program_year.presence

    if program_year.instance_of?(::Integer) && [1, 2].exclude?(program_year)
      raise "#{account_name} program year should be 1 or 2 : #{program_year}"
    end

    program_year
  end

  # Make sure all candidates are valid before saving.
  #
  # === Returns:
  #
  #
  # Boolean:
  #
  def validate_and_save_import
    if (imported_candidates.map do |cand|
      cand.candidate_sheet.while_not_validating_middle_name do
        cand.valid?
        cand.candidate_sheet.validate_emails # no longer part of save
        cand.errors.none? && cand.candidate_sheet.errors.none?
      end
    end).all?
      imported_candidates.each do |cand|
        cand.candidate_sheet.while_not_validating_middle_name do
          cand.save
        end
      end
      true
    else
      imported_candidates.each do |candidate_import|
        candidate_import.candidate_sheet.errors.full_messages.each do |message|
          errors.add :base, "Row #{@candidate_to_row[candidate_import]}: #{message}"
        end
      end
      false
    end
  end
end
