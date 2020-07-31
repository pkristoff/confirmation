# frozen_string_literal: true

#
# A helper class used for importing and exporting the DB information.
#
class CandidateImport
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  include FileHelper

  attr_accessor :uploaded_file
  attr_accessor :uploaded_zip_file
  attr_accessor :imported_candidates
  # check_events
  attr_accessor :missing_confirmation_events
  attr_accessor :found_confirmation_events
  attr_accessor :unknown_confirmation_events

  EXTRACTED_ZIP_DIR = 'temp'

  def self.image_columns
    %w[
      baptismal_certificate.scanned_certificate
      retreat_verification.scanned_retreat
      sponsor_covenant.scanned_covenant
      sponsor_eligibility.scanned_eligibility
    ]
  end

  def self.transient_columns
    %w[
      baptismal_certificate.certificate_picture baptismal_certificate.remove_certificate_picture
      retreat_verification.retreat_verification_picture retreat_verification.remove_retreat_verification_picture
      sponsor_covenant.sponsor_eligibility_picture sponsor_covenant.sponsor_covenant_picture
      sponsor_covenant.remove_sponsor_eligibility_picture sponsor_covenant.remove_sponsor_covenant_picture
    ]
  end

  # initialize new instance
  #
  # === Parameters:
  #
  # * <tt>:attributes</tt> name vaue pairs
  #
  # === Returns:
  #
  # * <tt>Hash</tt> of information to be verified
  #
  def initialize(attributes = {})
    attributes.each { |name, value| send("#{name}=", value) }
    @worksheet_conf_event_name = 'Confirmation Events'
    @worksheet_name = 'Candidates with events'
    # check_events
    @found_confirmation_events = []
    @missing_confirmation_events = []
    @unknown_confirmation_events = []
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
    filename = File.basename(file_path)
    filename
  end

  # Add events expectd to be missing
  #
  # === Parameters:
  #
  # * <tt>:missing_events</tt> Array: of expected missing ConfirmationEvents
  #
  # === Returns:
  #
  # * <tt>CandidateImport</tt> self
  #
  def add_missing_events(missing_events)
    missing_events.each do |event_key|
      confirmation_event = ConfirmationEvent.find_by(event_key: event_key)
      AppFactory.add_confirmation_event(event_key) if confirmation_event.nil?
      raise "Attempting to candidate_event named: #{event_key} that already exists.s" unless confirmation_event.nil?
    end
    check_events
  end

  # Check to seeif any ConfirmaEvents are missing.  It stores missing store in unknown_confirmation_events
  #
  # === Returns:
  #
  # * <tt>CandidateImport</tt> self
  #
  def check_events
    all_in_confirmation_event_keys = AppFactory.all_i18n_confirmation_event_keys
    unknowns = ConfirmationEvent.all.map(&:event_key)
    all_in_confirmation_event_keys.each do |event_key|
      unknowns_index = unknowns.index(event_key)
      unknowns.slice!(unknowns_index) unless unknowns_index.nil?
      confirmation_event = ConfirmationEvent.find_by(event_key: event_key)
      if confirmation_event.nil?
        missing_confirmation_events.push(event_key)
      else
        found_confirmation_events.push(event_key)
      end
    end
    unknowns.each do |confirmation_event_name|
      unknown_confirmation_events.push(confirmation_event_name)
    end
    self
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
    ans = validate_and_save_import
    Rails.logger.info "done load_initial_file: #{file.original_filename}"
    ans
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

  # Clear DB out for starting a new year.
  #
  def start_new_year
    clean_associations(Candidate)
    AppFactory.create_seed_candidate
    today = Time.zone.today
    ConfirmationEvent.find_each do |ce|
      ce.chs_due_date = today
      ce.the_way_due_date = today
      ce.save
    end

    Rails.logger.info 'done start new year'
  end

  # Used to start a new year - cleans out tables for new year.
  #
  # === Parameters:
  #
  # * <tt>:clazz</tt> Class: class under consideration
  # * <tt>:checked</tt> Array: of class already checked
  # * <tt>:do_not_destroy</tt> Array: of class not to destroy table entries.
  #
  def clean_associations(clazz, checked = [], do_not_destroy = [Admin, ConfirmationEvent])
    return if (checked.include? clazz) || (do_not_destroy.include? clazz)

    checked << clazz
    begin
      clazz.destroy_all
    rescue StandardError => e
      Rails.logger.info "cleaning association error when destroying #{clazz}"
      Rails.logger.info e.message
      Rails.logger.info e.backtrace.inspect
    end
    clazz.reflect_on_all_associations.each do |assoc|
      clean_associations(assoc.klass, checked)
    end
  end

  # Reset the database.  End up with only an admin + confirmation events and the candidate vickikristoff
  #
  def reset_database
    start_new_year

    remove_all_confirmation_events

    # save admin info because deleting all Admins
    admin = Admin.first
    contact_name = admin.contact_name
    contact_phone = admin.contact_phone
    admin_email = admin.email

    Admin.find_each(&:delete)

    # clean out Visitor
    Visitor.visitor('Change to home parish of confirmation',
                    'HTML for home page',
                    'HTML for about page',
                    'HTML for contact page')

    AppFactory.add_confirmation_events

    AppFactory.generate_seed(contact_name, contact_phone, admin_email)
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
  def to_xlsx(dir, from_spec = false)
    p = create_xlsx_package(dir, from_spec)
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
    ['baptismal_certificate.scanned_certificate', 'retreat_verification.scanned_retreat',
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
    %w[event_key index the_way_due_date chs_due_date instructions]
  end

  # Removes all ConfirmationEvent
  # public for TEST - Only
  #
  def remove_all_confirmation_events
    ConfirmationEvent.find_each(&:destroy)
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
  def create_xlsx_package(dir, from_spec = false)
    # http://www.rubydoc.info/github/randym/axlsx/Axlsx/Workbook:use_shared_strings
    p = Axlsx::Package.new(author: 'Admin')
    wb = p.workbook
    create_confirmation_event(wb)

    candidate_columns = xlsx_columns
    wb.add_worksheet(name: @worksheet_name) do |sheet|
      sheet.add_row candidate_columns
      candidate_order = Candidate.order(:account_name)
      expected_rows = candidate_order.size + 1
      candidate_order.each do |candidate|
        ExportExcelCandJob.new.perform(candidate.id, sheet, candidate_columns, dir) if from_spec
        ExportExcelCandJob.perform_async(candidate.id, sheet, candidate_columns, dir) unless from_spec
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
    when '.xlsx' then
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
        File.open(export_filename, 'wb') do |f|
          f.write image.content
        end
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
    legal_headers = %w[Last\ Name First\ Name Grade Teen\ Email Parent\ Email\ Address(es) Cardinal\ Gibbons\ HS\ Group]
    header_row = spreadsheet.first
    if header_row[0].strip == legal_headers[0] &&
       header_row[1].strip == legal_headers[1] &&
       header_row[2].strip == legal_headers[2] &&
       header_row[3].strip == legal_headers[3] &&
       header_row[4].strip == legal_headers[4] &&
       header_row[5].strip == legal_headers[5]

      (2..spreadsheet.last_row).each do |i|
        spreadsheet_row = spreadsheet.row(i)
        # skip empty row
        next if spreadsheet_row[0].nil? && spreadsheet_row[1].nil? && spreadsheet_row[2].nil? && spreadsheet_row[3].nil?

        last_name = spreadsheet_row[0].nil? ? '' : spreadsheet_row[0].strip
        first_name = spreadsheet_row[1].nil? ? '' : spreadsheet_row[1].strip
        # ruby fixnum is deprecating
        grade = if spreadsheet_row[2].class.to_s == 'Integer'
                  (spreadsheet_row[2].nil? ? '10th' : "#{spreadsheet_row[2]}th")
                else
                  (spreadsheet_row[2].nil? ? '10th' : spreadsheet_row[2].strip)
                end
        candidate_email = spreadsheet_row[3].nil? ? '' : spreadsheet_row[3].strip
        parent_email = spreadsheet_row[4].nil? ? '' : spreadsheet_row[4].strip
        cardinal_gibbons = spreadsheet_row[5].nil? ? '' : spreadsheet_row[5].strip

        candidate_sheet_params = ActionController::Parameters.new
        params = ActionController::Parameters.new(
          candidate: ActionController::Parameters.new(candidate_sheet_attributes: candidate_sheet_params)
        )

        candidate_sheet_params[:last_name] = last_name
        candidate_sheet_params[:first_name] = first_name
        candidate_sheet_params[:grade] = grade.empty? ? 10 : grade.slice(/^\D*[\d]*/)
        clean_item = ActionView::Base.full_sanitizer.sanitize(candidate_email)

        candidate_sheet_params[:candidate_email] = clean_item unless clean_item.empty?

        clean_item = ActionView::Base.full_sanitizer.sanitize(parent_email)
        unless clean_item.empty?
          item_split = clean_item.split(',')
          candidate_sheet_params[:parent_email_1] = item_split[0].strip
          candidate_sheet_params[:parent_email_2] = item_split[1].strip if item_split.size > 1
        end
        attending_way = I18n.t('views.candidates.attending_the_way')
        attending_chs = I18n.t('model.candidate.attending_catholic_high_school')
        candidate_sheet_params[:attending] = cardinal_gibbons.empty? ? attending_way : attending_chs

        account_name = Candidate.genertate_account_name(candidate_sheet_params[:last_name].gsub(/\s+/, '') || '',
                                                        candidate_sheet_params[:first_name].gsub(/\s+/, '') || '')
        params[:candidate][:account_name] = account_name
        params[:candidate][:password] = Event::Other::INITIAL_PASSWORD

        candidate = Candidate.find_by(account_name: account_name) || ::AppFactory.create_candidate
        candidate.update(params.require(:candidate).permit(Candidate.permitted_params))
        candidates.push(candidate)
        @candidate_to_row[candidate] = i
      end
      candidates
    else
      raise "Unknown spread sheet column: #{header_row} expected in order: #{legal_headers}"
    end
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
