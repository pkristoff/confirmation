class CandidateImport
  # switch to ActiveModel::Model in Rails 4
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :uploaded_file

  def initialize(attributes = {})
    attributes.each { |name, value| send("#{name}=", value) }
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
    @candidate_to_row = {}
    header = [:last_name, :first_name, :grade, :parent_email_1]
    spreadsheet = open_spreadsheet
    attending = 'The Way'
    candidates = []
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

          candidate_id = String.new(row[:last_name] || '').concat(row[:first_name] || '').downcase
          row[:candidate_id] = candidate_id
          row[:password] = '12345678'
          row[:attending] = attending

          candidate = Candidate.find_by_candidate_id(row[:candidate_id]) || Candidate.new
          candidate.attributes = row.to_hash.select { |k, v| Candidate.candidate_params.include? k }
          candidates.push(candidate)
          @candidate_to_row[candidate] = i
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
        # Roo::Spreadsheet.open(uploaded_file.path)
        Roo::Excelx.new(uploaded_file.path, file_warning: :ignore)
      else
        raise "Unknown file type: #{uploaded_file.original_filename}"
    end
  end

end