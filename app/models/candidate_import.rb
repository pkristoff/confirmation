class CandidateImport
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  include FileHelper

  attr_accessor :uploaded_file
  attr_accessor :uploaded_zip_file
  attr_accessor :imported_candidates

  def initialize(attributes = {})
    attributes.each { |name, value| send("#{name}=", value) }
    @worksheet_conf_event_name = 'Confirmation Events'
    @worksheet_name = 'Candidates with events'
  end

  def persisted?
    false
  end

  def create_xlsx_package(dir)
    p = Axlsx::Package.new(author: 'Admin')
    wb = p.workbook
    create_confirmation_event(wb)

    candidate_columns = xlsx_columns
    wb.add_worksheet(name: @worksheet_name) do |sheet|
      images = []
      sheet.add_row candidate_columns
      Candidate.all.each do |candidate|
        events = candidate.candidate_events.to_a
        sheet.add_row (candidate_columns.map do |col|
          if ['baptismal_certificate.certificate_filename', 'baptismal_certificate.certificate_content_type', 'baptismal_certificate.certificate_file_contents'].include?(col)
            certificate_image_column(candidate, col, dir, images)
          else
            # puts col
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
                  if events.size >= ConfirmationEvent.all.size
                    events[split[1].to_i].send(split[2])
                  else
                    'something wrong with candidate_events'
                  end
                end
              else
                "Unexpected split size: #{split.size}"
            end
          end
        end)
      end
      process_images(images)
    end
    p
  end

  def certificate_image_column(candidate, col, dir, images)
    if candidate.baptismal_certificate
      filename = CandidateImport.image_filename(candidate, dir)
      images.append({filename: filename,
                     info: candidate.baptismal_certificate}) if col === 'baptismal_certificate.certificate_filename'
      filename
    else
      'no candidate.baptismal_certificate'
    end
  end

  def create_confirmation_event(wb)
    confirmation_event_columns = xlsx_conf_event_columns
    wb.add_worksheet(name: @worksheet_conf_event_name) do |sheet|
      sheet.add_row confirmation_event_columns
      ConfirmationEvent.all.each do |confirmation_event|
        sheet.add_row (confirmation_event_columns.map do |col|
          confirmation_event.send(col)
        end)
      end
    end
  end

  def self.image_filename(candidate, dir)
    "#{dir}/#{candidate.account_name}_#{candidate.baptismal_certificate.certificate_filename}"
  end

  def imported_candidates
    @imported_candidates ||= load_imported_candidates
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
      candidates
    elsif uploaded_zip_file
      # zipped dir with xlsx and images.  this was generated via an export.
      # once expanded then set uploaded_file and recurse
      process_xlsx_zip
    end
  end

  def remove_all_candidates

    Candidate.all.each do |candidate|
      candidate.delete
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

  def save
    if imported_candidates.map(&:valid?).all?
      imported_candidates.each(&:save!)
      true
    else
      imported_candidates.each_with_index do |candidateImport, index|
        candidateImport.errors.full_messages.each do |message|
          errors.add :base, "Row #{@candidate_to_row[candidateImport]}: #{message}"
        end
      end
      false
    end
  end

  def to_xlsx(dir)
    p = create_xlsx_package(dir)
    p.use_shared_strings = true
    p
  end

  # test only
  def xlsx_columns
    columns = %w(account_name first_name last_name candidate_email parent_email_1
               parent_email_2 grade attending
               address.street_1 address.street_2 address.city address.state address.zip_code
               baptized_at_stmm
               baptismal_certificate.birth_date baptismal_certificate.baptismal_date baptismal_certificate.church_name
               baptismal_certificate.church_address.street_1 baptismal_certificate.church_address.street_2 baptismal_certificate.church_address.city baptismal_certificate.church_address.state baptismal_certificate.church_address.zip_code
               baptismal_certificate.father_first baptismal_certificate.father_middle baptismal_certificate.father_last
               baptismal_certificate.mother_first baptismal_certificate.mother_middle baptismal_certificate.mother_maiden baptismal_certificate.mother_last
               baptismal_certificate.certificate_filename baptismal_certificate.certificate_content_type baptismal_certificate.certificate_file_contents )
    ConfirmationEvent.all.each_with_index do |confirmation_event, index|
      columns << "candidate_events.#{index}.completed_date"
      columns << "candidate_events.#{index}.verified"
    end
    columns
  end

  # test only
  def xlsx_conf_event_columns
    %w{name due_date instructions}
  end

  private

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

  def process_exported_xlsx(candidates, spreadsheet)

    process_confirmation_events(spreadsheet)

    process_candidates(candidates, spreadsheet)
  end

  def process_candidates(candidates, spreadsheet)
    sheet = spreadsheet.sheet(@worksheet_name)
    header_row = sheet.row(1)
    account_name_index = header_row.find_index { |cell| cell == 'account_name' }
    (2..spreadsheet.last_row).each do |i|
      row = sheet.row(i)

      candidate = Candidate.find_by_account_name(row[account_name_index]) || AppFactory.create_candidate
      events = candidate.candidate_events.to_a
      row.each_with_index do |cell, index|
        column_name_split = header_row[index].split('.')
        # puts header_row[index]
        unless cell.nil?
          if column_name_split.size == 1
            candidate.send("#{column_name_split[0]}=", cell)

          elsif column_name_split.size == 2
            candidate.create_baptismal_certificate if candidate.baptismal_certificate.nil? && column_name_split[0] === 'baptismal_certificate'
            case column_name_split[1]

              when 'certificate_filename'
                unless cell === 'no candidate.baptismal_certificate'
                  filename = cell
                  candidate.baptismal_certificate.certificate_filename = filename[filename.index('_')+1..filename.size]
                end
              when 'certificate_content_type'
                unless cell === 'no candidate.baptismal_certificate'
                  filename = cell
                  file_extname = File.extname(filename)
                  candidate.baptismal_certificate.certificate_content_type = "type/#{file_extname[1..file_extname.size]}"
                end
              when 'certificate_file_contents'
                unless cell === 'no candidate.baptismal_certificate'
                  filename = cell
                  File.open(filename, 'rb') do |f|
                    candidate.baptismal_certificate.certificate_file_contents = f.read
                  end
                end
              else
                candidate.baptismal_certificate.create_church_address if column_name_split[1] === 'church_address' && candidate.baptismal_certificate.church_address.nil?
                candidate_send_0 = candidate.send(column_name_split[0])
                candidate_send_0.send("#{column_name_split[1]}=", cell)
            end

          elsif column_name_split.size == 3 && column_name_split[0] != 'candidate_events'
            candidate.create_baptismal_certificate if candidate.baptismal_certificate.nil? && column_name_split[0] === 'baptismal_certificate'
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
    sheet = spreadsheet.sheet(@worksheet_conf_event_name)
    header_row = sheet.row(1)
    name_index = header_row.find_index { |cell| cell == 'name' }
    (2..spreadsheet.last_row).each do |i|
      row = sheet.row(i)
      row.each_with_index do |cell, index|
        confirmation_event = ConfirmationEvent.find_by_name(row[name_index]) || AppFactory.add_confirmation_event(row[name_index])
        column_name_split = header_row[index].split('.')
        unless cell.nil?
          confirmation_event.send("#{column_name_split[0]}=", cell)
          confirmation_event.save
        end
      end
    end
  end

  def process_images(images)
    images.each do |entry|
      filename = entry[:filename]
      baptismal_certificate = entry[:info]
      begin
        f = File.new filename, "wb"
        f.write baptismal_certificate.certificate_file_contents
      ensure
        f.close
      end
    end
  end

  def process_initial_xlsx(candidates, spreadsheet)
    header = [:last_name, :first_name, :grade, :parent_email_1]
    attending = I18n.t('views.candidates.attending_the_way')
    (1..spreadsheet.last_row).each do |i|
      spreadsheet_row = spreadsheet.row(i)
      unless spreadsheet_row[0].nil? and spreadsheet_row[1].nil? and spreadsheet_row[2].nil? and spreadsheet_row[3].nil? # empty row
        if spreadsheet_row[1].nil? and spreadsheet_row[2].nil? and spreadsheet_row[3].nil?
          if spreadsheet_row[0].include?(I18n.t('views.candidates.attending_the_way'))
            attending = I18n.t('views.candidates.attending_the_way')
          else
            attending = I18n.t('model.candidate.attending_catholic_high_school')
          end
        else
          row = Hash.new
          spreadsheet_row.each_with_index do |item, index|
            item.strip! unless item.nil? or !(item.is_a? String)
            case header[index]
              when :grade
                if item.nil?
                  row[:grade] = 10
                else
                  row[:grade] = item.slice(/^\D*[\d]*/)
                end
              when :parent_email_1
                unless item.nil?
                  item_split = item.split(';')
                  row[:parent_email_1] = item_split[0].strip
                  row[:parent_email_2] = item_split[1].strip if item_split.size > 1
                end
              else
                row[header[index]] = item
            end
          end

          account_name = String.new(row[:last_name] || '').concat(row[:first_name] || '').downcase
          row[:account_name] = account_name
          row[:password] = '12345678'
          row[:attending] = attending

          candidate = Candidate.find_by_account_name(row[:account_name]) || ::AppFactory.create_candidate
          candidate.attributes = row.to_hash.select { |k, v| Candidate.candidate_params.include? k }
          candidates.push(candidate)
          @candidate_to_row[candidate] = i
        end
      end
    end
  end

  def open_spreadsheet
    is_zip = !uploaded_file.respond_to?(:original_filename)
    path = is_zip ? uploaded_file : uploaded_file.path
    case File.extname(is_zip ? File.basename(uploaded_file) : uploaded_file.original_filename)
      when '.csv' then
        Roo::Csv.new(path)
      when '.xls' then
        Roo::Excel.new(path)
      when '.xlsx' then
        Roo::Excelx.new(path, file_warning: :ignore)
      else
        raise "Unknown file type: #{uploaded_file.original_filename}"
    end
  end

  def remove_all_confirmation_events

    ConfirmationEvent.all.each do |candidate|
      candidate.delete
    end

  end

  def add_admin(email='confirmation@kristoffs.com', name='confirmation')

    admin = Admin.find_or_create_by!(email: email) do |admin|
      admin.name = name
      admin.password = Rails.application.secrets.admin_password
      admin.password_confirmation = Rails.application.secrets.admin_password
    end
    admin.save
  end

end