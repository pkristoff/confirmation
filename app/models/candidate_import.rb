class CandidateImport
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :uploaded_file

  def initialize(attributes = {})
    attributes.each { |name, value| send("#{name}=", value) }
    @worksheet_name = 'Candidates with address'
  end

  def persisted?
    false
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

  def imported_candidates
    @imported_candidates ||= load_imported_candidates
  end

  def load_imported_candidates
    candidates = []
    @candidate_to_row = {}
    header = [:last_name, :first_name, :grade, :parent_email_1]
    spreadsheet = open_spreadsheet
    if spreadsheet.sheets[0] == @worksheet_name
      sheet = spreadsheet.sheet(@worksheet_name)
      header_row = sheet.row(1)
      account_name_index = header_row.find_index { |cell| cell == 'account_name' }
      (2..spreadsheet.last_row).each do |i|
        row = sheet.row(i)

        candidate = Candidate.find_by_account_name(row[account_name_index]) || Candidate.new_with_address
        row.each_with_index do |cell, index|
          column_name_split = header_row[index].split('.')
          unless cell.nil?
            if column_name_split.size == 1
              candidate.send("#{column_name_split[0]}=", cell)
            else
              candidate.send(column_name_split[0]).send("#{column_name_split[1]}=", cell)
            end
          end
        end
        candidate.password = '12345678'
        candidates.push(candidate)
      end
    else
      attending = 'The Way'
      (1..spreadsheet.last_row).each do |i|
        spreadsheet_row = spreadsheet.row(i)
        unless spreadsheet_row[0].nil? and spreadsheet_row[1].nil? and spreadsheet_row[2].nil? and spreadsheet_row[3].nil? # empty row
          if spreadsheet_row[1].nil? and spreadsheet_row[2].nil? and spreadsheet_row[3].nil?
            if spreadsheet_row[0].include?('The Way')
              attending = 'The Way'
            else
              attending = 'Catholic High School'
            end
          else
            row = Hash.new
            spreadsheet_row.each_with_index do |item, index|
              item.strip! unless item.nil?
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

            candidate = Candidate.find_by_account_name(row[:account_name]) || Candidate.new_with_address
            candidate.attributes = row.to_hash.select { |k, v| Candidate.candidate_params.include? k }
            candidates.push(candidate)
            @candidate_to_row[candidate] = i
          end
        end
      end
    end
    candidates
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

  def remove_all_candidates

    Candidate.all.each do |candidate|
      candidate.delete
    end

  end

  def reset_database

    remove_all_candidates
    CreateTestCandidateService.new.call

    Admin.all.each do |admin|
      admin.delete
    end
    add_admin
  end

  def add_admin(email='confirmation@kristoffs.com', name='confirmation')

    admin = Admin.find_or_create_by!(email: email) do |admin|
      admin.name = name
      admin.password = Rails.application.secrets.admin_password
      admin.password_confirmation = Rails.application.secrets.admin_password
    end
    admin.save
  end

  def to_xlxs

    create_xlsx_package.to_stream
  end

  def xlsx_columns
    ['account_name', 'first_name', 'last_name', 'candidate_email', 'parent_email_1',
     'parent_email_2', 'grade', 'attending',
     'address.street_1', 'address.street_2', 'address.city', 'address.state', 'address.zip_code']
  end

  def create_xlsx_package
    columns = xlsx_columns
    p = Axlsx::Package.new(author: 'Admin')
    wb = p.workbook
    wb.add_worksheet(name: @worksheet_name) do |sheet|
      sheet.add_row columns
      Candidate.all.each do |candidate|
        sheet.add_row (columns.map do |col|
          split = col.split('.')
          if split.size == 1
            candidate.send(col)
          else
            candidate.send(split[0]).send(split[1])
          end
        end)
      end
    end
    p
  end

end