class Candidate < ActiveRecord::Base

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :authentication_keys => [:candidate_id],
         :reset_password_keys => [:candidate_id]

  validates :candidate_id,
            :presence => true,
            :uniqueness => {
                :case_sensitive => false
            }

  def self.find_first_by_auth_conditions(tainted_conditions, options = {})
    login = tainted_conditions.delete(:candidate_id)
    if login
      conditions = devise_parameter_filter.filter(value: login.downcase)
      where(['lower(candidate_id) = :value OR lower(parent_email_1) = :value', conditions]).first
    else
      super
    end
  end

  def email
    self.parent_email_1
  end

  def email=(value)
    self.parent_email_1= value
  end

  def email_required?
    false
  end

  def email_changed?
    false
  end

  def self.import(uploaded_file)
    header = [:last_name, :first_name, :grade, :parent_email_1, :parent_email_2]
    allowed_attributes = header.concat([:candidate_id, :password])
    spreadsheet = open_spreadsheet(uploaded_file)
    attending = 'The Way'
    (1..spreadsheet.last_row).each do |i|
      spreadsheet_row = spreadsheet.row(i)
      if !spreadsheet_row[0].nil? # empty row
        if spreadsheet_row[1].nil?
          if spreadsheet_row[0].include?('The Way')
            attending = 'The Way'
          else
            attending = 'Catholic High School'
          end
        else
          row = Hash.new
          spreadsheet_row.each_with_index do |item, index|
            case header[index]
              when :grade
                if item.nil?
                  row[:grade] = 10
                else
                  row[:grade] = item.slice(/^\D*[\d]*/)
                end
              when :parent_email_1
                item_split = item.split(',')
                row[:parent_email_1] = item_split[0]
                row[:parent_email_2] = item_split[1] if item_split.size > 1
              else
                row[header[index]] = item
            end
          end

          candidate_id = row[:last_name].concat(row[:first_name]).downcase!
          row[:candidate_id] = candidate_id
          row[:password] = '12345678'

          candidate = find_by_candidate_id(row[:candidate_id]) || new
          candidate.attributes = row.to_hash.select { |k, v| allowed_attributes.include? k }
          candidate.save!
        end
      end
    end
  end


  def self.open_spreadsheet(uploaded_file)
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
