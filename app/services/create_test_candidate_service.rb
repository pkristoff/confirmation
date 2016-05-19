class CreateTestCandidateService
  def call
    candidate = Candidate.find_or_create_by!(candidate_id: 'vickikristoff') do |candidate|
      candidate.parent_email_1 = 'paul@kristoffs.com'
      candidate.first_name = 'Vicki'
      candidate.last_name = 'Kristoff'
      candidate.password = Rails.application.secrets.admin_password
      candidate.password_confirmation = Rails.application.secrets.admin_password
    end
    candidate.save
  end
end