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

  def initialize(attributes = {})
    attributes.each {|name, value| send("#{name}=", value)}
    @worksheet_conf_event_name = 'Confirmation Events'
    @worksheet_name = 'Candidates with events'
    # check_events
    @found_confirmation_events = []
    @missing_confirmation_events = []
    @unknown_confirmation_events = []
  end

  def self.image_filepath_export(candidate, dir, columns)
    association_method, filename_method = columns.split('.')
    image_filename = candidate.send(association_method).send(filename_method)
    image_filename = '' if image_filename.nil?
    "#{dir}/#{candidate.account_name}_#{filename_method}_#{File.basename(image_filename)}"
  end

  def self.image_filename_import(file_path)
    filename = File.basename(file_path)
    filename
  end

  def add_missing_events (missing_events)
    missing_events.each do |event_name|
      confirmation_event = ConfirmationEvent.find_by_name(event_name)
      if confirmation_event.nil?
        AppFactory.add_confirmation_event(event_name)
      else
        raise "Attempting to candidate_event named: #{event_name} that already exists.s"
      end
    end
    check_events
  end

  def check_events
    all_in_confirmation_event_names = AppFactory.all_i18n_confirmation_event_names
    unknowns = ConfirmationEvent.all.map {|ce| ce.name}
    all_in_confirmation_event_names.each do |i18n_key|
      confirmation_event_name = I18n.t(i18n_key)
      unknowns_index = unknowns.index(confirmation_event_name)
      unknowns.slice!(unknowns_index) unless unknowns_index.nil?
      confirmation_event = ConfirmationEvent.find_by_name(confirmation_event_name)
      if confirmation_event.nil?
        missing_confirmation_events.push(confirmation_event_name)
      else
        found_confirmation_events.push(confirmation_event_name)
      end
    end
    unknowns.each do |confirmation_event_name|
      unknown_confirmation_events.push(confirmation_event_name)
    end
    self
  end

  def load_initial_file(file)
    @uploaded_file = file
    @imported_candidates = load_imported_candidates
    validate_and_save_import
  end

  def load_zip_file(file)
    @uploaded_zip_file = file
    @imported_candidates = load_imported_candidates
    validate_and_save_import
  end

  def persisted?
    false
  end

  def remove_all_candidates

    Candidate.all.each do |candidate|
      candidate.destroy
    end

  end

  def reset_database

    remove_all_candidates

    remove_all_confirmation_events

    Admin.all.each do |admin|
      admin.delete
    end

    AppFactory.add_confirmation_events

    AppFactory.generate_seed
  end

  def to_xlsx(dir)
    p = create_xlsx_package(dir)
    # the Package will be generated with a shared string table
    p.use_shared_strings = true
    p
  end

  # test only
  def xlsx_columns
    params = Candidate.get_permitted_params
    columns = []
    get_columns(params, columns)
    columns.delete(:password)
    columns.delete(:password_confirmation)
    (0..get_confirmation_events_sorted.length-1).each do |index|
      columns << "candidate_events.#{index}.completed_date"
      columns << "candidate_events.#{index}.verified"
    end
    columns
  end

  # test only
  def xlsx_conf_event_columns
    %w{name index the_way_due_date chs_due_date instructions}
  end

  private

  def candidate_events_in_order (candidate)
    events = []
    @events_in_order.each do |confirmation_event|
      events << (candidate.get_candidate_event(confirmation_event.name))
    end
    events
  end

  def content_type (type)
    return type if type.nil? || type.empty?
    type.split('/')[1]
  end

  # setsup images to write file info out.
  # ..._filename = original filename
  # ..._content_type = content_type
  # ..._file_cotent = new filename
  def certificate_image_column(candidate, col, dir, images)
    if col.include? 'baptismal_certificate'
      association = candidate.baptismal_certificate
      if association
        if col.include? 'certificate_filename'
          association.certificate_filename
        elsif col.include? 'certificate_content_type'
          content_type(association.certificate_content_type)
        elsif col.include? 'certificate_file_contents'
          new_filename = CandidateImport.image_filepath_export(candidate, dir, 'baptismal_certificate.certificate_filename')
          images.append({filename: new_filename,
                         info: association})
          new_filename
        else
          raise "unknown col #{col}"
        end
      else
        'no candidate.baptismal_certificate'
      end
    elsif col.include? 'retreat_verification'
      association = candidate.retreat_verification
      if association
        if col.include? 'retreat_filename'
          association.retreat_filename
        elsif col.include? 'retreat_content_type'
          content_type(association.retreat_content_type)
        elsif col.include? 'retreat_file_content'
          new_filename = CandidateImport.image_filepath_export(candidate, dir, 'retreat_verification.retreat_filename')
          images.append({filename: new_filename,
                         info: association})
          new_filename
        else
          raise "unknown col #{col}"
        end
      else
        'no candidate.retreat_verification'
      end
    elsif col.include? 'sponsor_covenant.sponsor_elegibility'
      association = candidate.sponsor_covenant
      if association
        if col.include? 'sponsor_elegibility_filename'
          association.sponsor_elegibility_filename
        elsif col.include? 'sponsor_elegibility_content_type'
          content_type(association.sponsor_elegibility_content_type)
        elsif col.include? 'sponsor_elegibility_file_contents'
          new_filename = CandidateImport.image_filepath_export(candidate, dir, 'sponsor_covenant.sponsor_elegibility_filename')
          images.append({filename: new_filename,
                         info: association})
          new_filename
        else
          raise "unknown col #{col}"
        end
      else
        'no candidate.sponsor_covenant'
      end
    elsif col.include? 'sponsor_covenant.sponsor_covenant'
      association = candidate.sponsor_covenant
      if association
        if col.include? 'sponsor_covenant_filename'
          association.sponsor_covenant_filename
        elsif col.include? 'sponsor_covenant_content_type'
          content_type(association.sponsor_covenant_content_type)
        elsif col.include? 'sponsor_covenant_file_contents'
          new_filename = CandidateImport.image_filepath_export(candidate, dir, 'sponsor_covenant.sponsor_covenant_filename')
          images.append({filename: new_filename,
                         info: association})
          new_filename
        else
          raise "unknown col #{col}"
        end
      else
        'no candidate.sponsor_covenant'
      end
    end
  end

  def create_confirmation_event(wb)
    confirmation_event_columns = xlsx_conf_event_columns
    wb.add_worksheet(name: @worksheet_conf_event_name) do |sheet|
      sheet.add_row confirmation_event_columns
      get_confirmation_events_sorted.each_with_index do |confirmation_event, index|
        # puts "Event: #{confirmation_event.name} index:#{index}"
        sheet.add_row (confirmation_event_columns.map do |col|
          if col === 'index'
            index
          else
            # Rails.logger.info "xxx create_confirmation_event event:#{confirmation_event.name} instructions encoding: #{confirmation_event.send(col).encoding}" if col === 'instructions'
            confirmation_event.send(col)
          end
        end)
      end
    end
  end

  def create_xlsx_package(dir)
    image_columns = %w(
        baptismal_certificate.certificate_filename baptismal_certificate.certificate_content_type baptismal_certificate.certificate_file_contents
        retreat_verification.retreat_filename retreat_verification.retreat_content_type retreat_verification.retreat_file_content
        sponsor_covenant.sponsor_elegibility_filename sponsor_covenant.sponsor_elegibility_content_type sponsor_covenant.sponsor_elegibility_file_contents
        sponsor_covenant.sponsor_covenant_filename sponsor_covenant.sponsor_covenant_content_type sponsor_covenant.sponsor_covenant_file_contents
)
    # http://www.rubydoc.info/github/randym/axlsx/Axlsx/Workbook:use_shared_strings
    p = Axlsx::Package.new(author: 'Admin')
    wb = p.workbook
    create_confirmation_event(wb)

    candidate_columns = xlsx_columns
    wb.add_worksheet(name: @worksheet_name) do |sheet|
      images = []
      sheet.add_row candidate_columns
      Candidate.order(:account_name).each do |candidate|
        Rails.logger.info "xxx create_xlsx_package processing candidate:#{candidate.account_name}"
        events = get_confirmation_events_sorted
        sheet.add_row (candidate_columns.map do |col|
          if image_columns.include?(col)
            Rails.logger.info "   xxx create_xlsx_package Image:#{candidate.account_name} #{col}"
            certificate_image_column(candidate, col, dir, images)
          else
            # puts col
            val = get_column_value(candidate, col, events)
            # Rails.logger.info "col=#{col} val=#{val}"
            val
          end
        end)
      end
      process_images(images)
    end
    p
  end

  def get_column_value(candidate, col, confirmation_events)
    split = col.split('.')
    case split.size
      when 1
        candidate.send(col)
      when 2
        candidate_send_0 = candidate.send(split[0])
        if candidate_send_0.nil?
          nil
        else
          candidate_send_0.send(split[1])
        end
      when 3
        if split[0] != 'candidate_events'
          candidate_send_0 = candidate.send(split[0])
          if candidate_send_0.nil?
            nil
          else
            candidate_send_0.send(split[1]).send(split[2])
          end
        else
          confirmation_event = confirmation_events[split[1].to_i]
          cand_event = candidate.get_candidate_event(confirmation_event.name)
          cand_event.send(split[2])
        end
      else
        "Unexpected split size: #{split.size}"
    end
  end

  def get_columns (params, columns, prefix='')
    return columns if params.empty?
    params.each do |param|
      if param.is_a?(Hash)
        param.keys.each do |key|
          unless key === :candidate_events_attributes
            key_str = key.to_s
            xxx = key_str[0, key_str.size-('_attributes'.size)]
            get_columns(param[key], columns, (prefix.empty? ? xxx : "#{prefix}.#{xxx}"))
          end
        end
      else
        columns << (prefix.empty? ? param.to_s : "#{prefix}.#{param.to_s}")
      end
    end
  end

  def get_confirmation_events_sorted
    ConfirmationEvent.order(:name)
  end

  def load_imported_candidates
    # uploaded_file is an xlsx, either initial file or an exported file.
    if uploaded_file
      candidates = []
      @candidate_to_row = {}
      spreadsheet = open_spreadsheet
      if spreadsheet.sheets[0] == @worksheet_name or spreadsheet.sheets[0] == @worksheet_conf_event_name
        process_exported_xlsx(candidates, spreadsheet)
      else
        process_initial_xlsx(candidates, spreadsheet)
      end
      spreadsheet.close
      candidates
    elsif uploaded_zip_file
      # zipped dir with xlsx and images.  this was generated via an export.
      # once expanded then set uploaded_file and recurse
      process_xlsx_zip
    end
  end

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

  def process_candidates(candidates, spreadsheet)
    sheet = spreadsheet.sheet(@worksheet_name)
    header_row = sheet.row(1)
    account_name_index = header_row.find_index {|cell| cell == 'account_name'}
    (2..spreadsheet.last_row).each do |i|
      row = sheet.row(i)

      candidate = Candidate.find_by_account_name(row[account_name_index]) || AppFactory.create_candidate
      events = candidate_events_in_order(candidate)
      row.each_with_index do |cell, index|
        column_name_split = header_row[index].split('.')
        # puts header_row[index]
        unless cell.nil?
          if column_name_split.size == 1
            candidate.send("#{column_name_split[0]}=", cell)

          elsif column_name_split.size == 2
            case column_name_split[1]

              when 'certificate_filename'
                  filename = cell
                  candidate.baptismal_certificate.certificate_filename = CandidateImport.image_filename_import(filename)
              when 'certificate_content_type'
                  filename = cell
                  file_extname = File.extname(filename)
                  candidate.baptismal_certificate.certificate_content_type = "type/#{cell}"
              when 'certificate_file_contents'
                  filename = cell
                  File.open(filename, 'rb') do |f|
                    candidate.baptismal_certificate.certificate_file_contents = f.read
                  end
              when 'retreat_filename'
                  filename = cell
                  candidate.retreat_verification.retreat_filename = CandidateImport.image_filename_import(filename)
              when 'retreat_content_type'
                  filename = cell
                  file_extname = File.extname(filename)
                  candidate.retreat_verification.retreat_content_type = "type/#{cell}"
              when 'retreat_file_content'
                  filename = cell
                  File.open(filename, 'rb') do |f|
                    candidate.retreat_verification.retreat_file_content = f.read
                  end
              when 'sponsor_elegibility_filename'
                  filename = cell
                  candidate.sponsor_covenant.sponsor_elegibility_filename = CandidateImport.image_filename_import(filename)
              when 'sponsor_elegibility_content_type'
                  filename = cell
                  file_extname = File.extname(filename)
                  candidate.sponsor_covenant.sponsor_elegibility_content_type = "type/#{cell}"
              when 'sponsor_elegibility_file_contents'
                  filename = cell
                  File.open(filename, 'rb') do |f|
                    candidate.sponsor_covenant.sponsor_elegibility_file_contents = f.read
                  end
              when 'sponsor_covenant_filename'
                  filename = cell
                  candidate.sponsor_covenant.sponsor_covenant_filename = CandidateImport.image_filename_import(filename)
              when 'sponsor_covenant_content_type'
                  filename = cell
                  file_extname = File.extname(filename)
                  candidate.sponsor_covenant.sponsor_covenant_content_type = "type/#{cell}"
              when 'sponsor_covenant_file_contents'
                  filename = cell
                  File.open(filename, 'rb') do |f|
                    candidate.sponsor_covenant.sponsor_covenant_file_contents = f.read
                  end
              else
                candidate.baptismal_certificate.create_church_address if column_name_split[1] === 'church_address' && candidate.baptismal_certificate.church_address.nil?
                candidate_send_0 = candidate.send(column_name_split[0])
                candidate_send_0.send("#{column_name_split[1]}=", cell)
            end

          elsif column_name_split.size == 3 && column_name_split[0] != 'candidate_events'
            candidate.baptismal_certificate.create_church_address if column_name_split[1] === 'church_address' && candidate.baptismal_certificate.church_address.nil?
            candidate_send_0 = candidate.send(column_name_split[0])
            if candidate_send_0.nil?
              nil
            else
              candidate_send__send = candidate_send_0.send(column_name_split[1])
              candidate_send__send.send("#{column_name_split[2]}=", cell)
            end
          else
            events[column_name_split[1].to_i].send("#{column_name_split[2]}=", cell) if column_name_split.size === 3
          end
        end
      end
      candidate.password = '12345678'
      candidates.push(candidate)
    end
  end

  def process_confirmation_events(spreadsheet)
    @events_in_order = []
    sheet = spreadsheet.sheet(@worksheet_conf_event_name)
    header_row = sheet.row(1)
    name_index = header_row.find_index {|cell| cell == 'name'}
    (2..spreadsheet.last_row).each do |i|
      row = sheet.row(i)
      confirmation_event = ConfirmationEvent.find_by_name(row[name_index]) || AppFactory.add_confirmation_event(row[name_index])
      row.each_with_index do |cell, index|
        column_name_split = header_row[index].split('.')
        unless cell.nil?
          unless column_name_split[0] === 'index'
            confirmation_event.send("#{column_name_split[0]}=", cell)
          end
        end
      end
      confirmation_event.save
      @events_in_order << confirmation_event
      # puts "#{i-2}: #{confirmation_event.name}:#{confirmation_event.the_way_due_date.to_s}:#{confirmation_event.chs_due_date.to_s}"
    end
  end

  def process_exported_xlsx(candidates, spreadsheet)

    process_confirmation_events(spreadsheet)

    process_candidates(candidates, spreadsheet)
  end

  def process_images(images)
    images.each do |entry|
      filename = entry[:filename]
      association = entry[:info]
      file_contents = if filename.include? 'elegibility'
                        association.sponsor_elegibility_file_contents
                      else
                        association.file_contents
                      end

      File.open(filename, mode='wb') do |f|
        f.write file_contents
      end
    end
  end

  def process_initial_xlsx(candidates, spreadsheet)
    header_row = spreadsheet.first
    if header_row[0].strip === 'Last Name' &&
        header_row[1].strip === 'First Name' &&
        header_row[3].strip === 'Grade' &&
        header_row[6].strip === 'Teen Email' &&
        header_row[7].strip === 'Parent Email Address(es)' &&
        header_row[8].strip === 'Cardinal Gibbons HS Group'

      (2..spreadsheet.last_row).each do |i|
        spreadsheet_row = spreadsheet.row(i)

        unless spreadsheet_row[0].nil? and spreadsheet_row[1].nil? and spreadsheet_row[2].nil? and spreadsheet_row[3].nil? # skip empty row

          last_name = spreadsheet_row[0].nil? ? '' : spreadsheet_row[0].strip
          first_name = spreadsheet_row[1].nil? ? '' : spreadsheet_row[1].strip
          grade = (spreadsheet_row[3].nil? ? '10th' : spreadsheet_row[3].strip) unless spreadsheet_row[3].class.to_s === 'Fixnum'
          grade = (spreadsheet_row[3].nil? ? '10th' : "#{spreadsheet_row[3]}th") if spreadsheet_row[3].class.to_s === 'Fixnum'
          candidate_email = spreadsheet_row[6].nil? ? '' : spreadsheet_row[6].strip
          parent_email = spreadsheet_row[7].nil? ? '' : spreadsheet_row[7].strip
          cardinal_gibbons = spreadsheet_row[8].nil? ? '' : spreadsheet_row[8].strip

          candidate_sheet_params = ActionController::Parameters.new
          params = ActionController::Parameters.new(candidate: ActionController::Parameters.new(candidate_sheet_attributes: candidate_sheet_params))

          candidate_sheet_params[:last_name] = last_name
          candidate_sheet_params[:first_name] = first_name
          candidate_sheet_params[:grade] = grade.empty? ? 10 : grade.slice(/^\D*[\d]*/)
          clean_item = ActionView::Base.full_sanitizer.sanitize(candidate_email)
          unless clean_item.empty?
            candidate_sheet_params[:candidate_emailfirst_name] = clean_item
          end
          clean_item = ActionView::Base.full_sanitizer.sanitize(parent_email)
          unless clean_item.empty?
            item_split = clean_item.split(',')
            candidate_sheet_params[:parent_email_1] = item_split[0].strip
            candidate_sheet_params[:parent_email_2] = item_split[1].strip if item_split.size > 1
          end
          candidate_sheet_params[:attending] = cardinal_gibbons.empty? ? I18n.t('views.candidates.attending_the_way') : I18n.t('model.candidate.attending_catholic_high_school')

          account_name = String.new(candidate_sheet_params[:last_name].gsub(/\s+/, '') || '').concat(candidate_sheet_params[:first_name].gsub(/\s+/, '') || '').downcase
          params[:candidate][:account_name] = account_name
          params[:candidate][:password] = '12345678'

          candidate = Candidate.find_by_account_name(account_name) || ::AppFactory.create_candidate
          candidate.update_attributes(params.require(:candidate).permit(Candidate.get_permitted_params))
          candidates.push(candidate)
          @candidate_to_row[candidate] = i
        end
      end
      candidates
    else
      raise "Unknown spread sheet columns: #{header_row.to_s}"
    end
  end

  # expand zip file and the process xlsx
  def process_xlsx_zip
    dir = 'xlsx_export'

    delete_dir(dir)

    begin
      Dir.mkdir(dir)

      Zip::File.open(uploaded_zip_file.tempfile) do |zip_file|
        # Handle entries one by one
        zip_file.each do |entry|
          # Extract to file/directory/symlink
          # puts "Extracting #{entry.name}"
          entry.extract("#{dir}/#{entry.name}")
          if File.extname(entry.name) == '.xlsx' && @uploaded_file.nil?
            @uploaded_file = "#{dir}/#{entry.name}"
          end
        end
      end
      load_imported_candidates
    ensure
      delete_dir(dir)
    end
  end

  def remove_all_confirmation_events

    ConfirmationEvent.all.each do |confirmation_event|
      confirmation_event.delete
    end

  end

  def validate_and_save_import
    if imported_candidates.map(&:valid?).all?
      imported_candidates.each(&:save!)
      true
    else
      imported_candidates.each do |candidateImport|
        candidateImport.errors.full_messages.each do |message|
          errors.add :base, "Row #{@candidate_to_row[candidateImport]}: #{message}"
        end
      end
      false
    end
  end

end