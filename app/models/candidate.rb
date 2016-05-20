class Candidate < ActiveRecord::Base

  belongs_to(:address)
  accepts_nested_attributes_for :address, allow_destroy: true

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
  validates_presence_of :first_name, :last_name, :parent_email_1
  validate :validate_emails

  def self.find_first_by_auth_conditions(tainted_conditions, options = {})
    login = tainted_conditions.delete(:candidate_id)
    if login
      conditions = devise_parameter_filter.filter(value: login.downcase)
      where(['lower(candidate_id) = :value OR lower(parent_email_1) = :value', conditions]).first
    else
      super
    end
  end

  # Could not figure out the "Ruby Way" for creating an associated object.
  # so decided to use this.
  def self.new_with_address
    candidate = Candidate.new
    candidate.build_address
    candidate
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

  def self.candidate_params
    params = attribute_names.collect{|e| e.to_sym} & [:last_name, :first_name, :grade, :parent_email_1, :parent_email_2, :candidate_id, :password, :attending]
    params = params << :password
    params
  end

  def validate_emails
    unless candidate_email.nil? or candidate_email.empty?
      errors.add(:candidate_email, "is an invalid email") unless validate_email(candidate_email)
    end
    unless parent_email_1.nil? or parent_email_1.empty?
      errors.add(:parent_email_1, "is an invalid email") unless validate_email(parent_email_1)
    end
    unless parent_email_2.nil? or parent_email_2.empty?
      errors.add(:parent_email_2, "is an invalid email") unless validate_email(parent_email_2)
    end

  end

  def validate_email(value)
    value =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  end

end
