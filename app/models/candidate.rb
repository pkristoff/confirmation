class Candidate < ActiveRecord::Base

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :authentication_keys => [:candidate_id]

  validates :candidate_id,
            :presence => true,
            :uniqueness => {
                :case_sensitive => false
            }

  def email_required?
    false
  end

  def email_changed?
    false
  end
end
