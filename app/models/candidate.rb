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
end
