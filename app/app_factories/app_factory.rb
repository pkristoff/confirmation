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
    add_candidate_events(candidate)
    candidate
  end

  def self.add_candidate_events(candidate)
    ConfirmationEvent.all.each do |confirmation_event|
      candidate.add_candidate_event(confirmation_event)
    end
  end

  def self.revert_confirmation_event(event_name)
    # puts "reverting: #{event_name}"
    Candidate.all.each do |candidate|
      # puts "reverting candidate: #{candidate.account_name}"
      founds = candidate.candidate_events.select { |candidate_event| candidate_event.confirmation_event.nil? or candidate_event.name == event_name }
      founds.each do |found|
        # puts "found candidate_event: #{found.name}" unless found.confirmation_event.nil?
        # puts "found empty confirmation_event" if found.confirmation_event.nil?
        candidate.candidate_events.delete(found)
        found.destroy
      end

    end
    # puts 'about to destroy ConfirmationEvent'
    confirmation_event = ConfirmationEvent.find_by(name: event_name)
    confirmation_event.destroy unless confirmation_event.nil?
    # puts "done reverting: #{event_name}"
  end

  def self.add_confirmation_event(event_name)
    # puts 'starting event_name'
    new_confirmation_event = nil
    event = ConfirmationEvent.find_or_create_by!(name: event_name) do |confirmation_event|
      confirmation_event.name = event_name
      confirmation_event.due_date = Date.today
      new_confirmation_event = confirmation_event
      # puts "new created #{confirmation_event.name} id: #{confirmation_event.id} due_date = #{confirmation_event.due_date}"
    end
    unless new_confirmation_event.nil?
      # puts 'adding to candidates'
      Candidate.all.each do |candidate|
        candidate.add_candidate_event(new_confirmation_event)
        # puts "adding to candidate: #{candidate.account_name}"
        candidate.save
      end
    end
    # puts 'ending event_name'
    event
  end

  def self.generate_seed
    Admin.find_or_create_by!(email: Rails.application.secrets.admin_email) do |admin|
      admin.name = Rails.application.secrets.admin_name
      admin.password = Rails.application.secrets.admin_password
      admin.password_confirmation = Rails.application.secrets.admin_password
    end
    create_seed_candidate(ConfirmationEvent.all)

  end

  private

  def self.create_candidate_event(confirmation_event)
    candidate_event = CandidateEvent.new
    candidate_event.verified = false
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
      self.add_candidate_events(candidate)
    end
  end

  def self.add_confirmation_events
    # matches 20160603111604_add_parent_information_meeting.rb
    self.add_confirmation_event(I18n.t('events.parent_meeting'))
    # matches 20160603161241_add_attend_retreat.rb
    self.add_confirmation_event(I18n.t('events.retreat_weekend'))
    # matches 20160701175828_add_convenant_agreement.rb
    self.add_confirmation_event(I18n.t('events.sign_agreement'))
  end

end
