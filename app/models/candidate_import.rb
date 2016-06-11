class CandidateImport
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :uploaded_file

  def initialize(attributes = {})
    attributes.each { |name, value| send("#{name}=", value) }
    @worksheet_conf_event_name = 'Confirmation Events'
    @worksheet_name = 'Candidates with events'
  end

  def persisted?
    false
  end

  def create_xlsx_package
    p = Axlsx::Package.new(author: 'Admin')
    wb = p.workbook
    confirmation_event_columns = xlsx_conf_event_columns
    wb.add_worksheet(name: @worksheet_conf_event_name) do |sheet|
      sheet.add_row confirmation_event_columns
      ConfirmationEvent.all.each do |confirmation_event|
        sheet.add_row (confirmation_event_columns.map do |col|
          confirmation_event.send(col)
        end)
      end
    end

    candidate_columns = xlsx_columns
    wb.add_worksheet(name: @worksheet_name) do |sheet|
      sheet.add_row candidate_columns
      Candidate.all.each do |candidate|
        events = candidate.candidate_events.to_a
        sheet.add_row (candidate_columns.map do |col|
          split = col.split('.')
          if split.size == 1
            candidate.send(col)
          elsif split.size == 2
            candidate.send(split[0]).send(split[1])
          else
            if events.size >= ConfirmationEvent.all.size
              events[split[1].to_i].send(split[2])
            else
              'something wrong with candidate_events'
            end
          end
        end)
      end
    end
    p
  end

  def imported_candidates
    @imported_candidates ||= load_imported_candidates
  end

  def load_imported_candidates
    candidates = []
    @candidate_to_row = {}
    spreadsheet = open_spreadsheet
    if spreadsheet.sheets[0] == @worksheet_name or spreadsheet.sheets[0] == @worksheet_conf_event_name
      process_exported_xlsx(candidates, spreadsheet)
    else
      process_initial_xlsx(candidates, spreadsheet)
    end
    candidates
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
    # matches 20160603111604_add_parent_information_meeting.rb
    AppFactory.add_confirmation_event(I18n.t('events.parent_meeting'))
    # matches 20160603161241_add_attend_retreat.rb
    AppFactory.add_confirmation_event(I18n.t('events.retreat_weekend'))
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

  def to_xlsx
    create_xlsx_package.to_stream
  end

  # test only
  def xlsx_columns
    columns = %w(account_name first_name last_name candidate_email parent_email_1
               parent_email_2 grade attending
               address.street_1 address.street_2 address.city address.state address.zip_code)
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
        unless cell.nil?
          if column_name_split.size == 1
            candidate.send("#{column_name_split[0]}=", cell)
          elsif column_name_split.size == 2
            candidate.send(column_name_split[0]).send("#{column_name_split[1]}=", cell)
          else
            events[column_name_split[1].to_i].send("#{column_name_split[2]}=", cell)
          end
        end
        candidate.password = '12345678'
      end
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
    case File.extname(uploaded_file.original_filename)
      when '.csv' then
        Roo::Csv.new(uploaded_file.path)
      when '.xls' then
        Roo::Excel.new(uploaded_file.path)
      when '.xlsx' then
        Roo::Excelx.new(uploaded_file.path, file_warning: :ignore)
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