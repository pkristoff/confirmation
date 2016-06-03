class AppFactory

  def self.create(resource_class)
    resource_class == Candidate ? create_candidate : create_admin
  end

  def self.create_admin(options={})
    Admin.new(options)
  end

  def self.create_candidate
    candidate = Candidate.new
    candidate.build_address
    ConfirmationEvent.all.each do |confirmation_event|
      candidate.add_candidate_event(confirmation_event)
    end
    candidate
  end

  def self.add_parent_information_meeting_migration
    puts 'starting add_parent_information_meeting_migration'
    new_candidate_event = nil
    parent_info_meeting_event = ConfirmationEvent.find_or_create_by!(name: 'Parent Information Meeting') do |confirmation_event|
      confirmation_event.name = 'Parent Information Meeting'
      confirmation_event.due_date = Date.today
      new_candidate_event = confirmation_event
      puts "new created #{confirmation_event.name} id: #{confirmation_event.id} due_date = #{confirmation_event.due_date}"
    end
    unless new_candidate_event.nil?
      puts 'adding to candidates'
      Candidate.all.each do |candidate|
        candidate.add_candidate_event(parent_info_meeting_event)
        puts "adding to candidate: #{candidate.account_name}"
        candidate.save
      end
    end
    puts 'ending add_parent_information_meeting_migration'
  end

  def self.generate_seed
    admin = Admin.find_or_create_by!(email: Rails.application.secrets.admin_email) do |admin|
      admin.name = Rails.application.secrets.admin_name
      admin.password = Rails.application.secrets.admin_password
      admin.password_confirmation = Rails.application.secrets.admin_password
    end
    candidate = create_seed_candidate([parent_info_meeting_event])

  end

  private

  def self.create_candidate_event(confirmation_event)
    candidate_event = CandidateEvent.new
    candidate_event.confirmation_event = confirmation_event
    candidate_event
  end

  def self.create_seed_candidate(confirmation_events = ConfirmationEvent.all)
    Candidate.find_or_create_by!(account_name: 'vickikristoff') do |candidate|
      candidate.create_address
      candidate.parent_email_1 = 'paul@kristoffs.com'
      candidate.first_name = 'Vicki'
      candidate.last_name = 'Kristoff'
      candidate.grade = 10
      candidate.password = Rails.application.secrets.admin_password
      candidate.password_confirmation = Rails.application.secrets.admin_password
      confirmation_events.each do |confirmation_event|
        candidate.add_candidate_event(confirmation_event)
      end
    end
  end

end
