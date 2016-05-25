class CreateTestCandidateService
  def call
    candidate = Candidate.find_or_create_by!(account_name: 'vickikristoff') do |candidate|
      candidate.create_address
      candidate.parent_email_1 = 'paul@kristoffs.com'
      candidate.first_name = 'Vicki'
      candidate.last_name = 'Kristoff'
      candidate.password = Rails.application.secrets.admin_password
      candidate.password_confirmation = Rails.application.secrets.admin_password
    end
    candidate
  end
end