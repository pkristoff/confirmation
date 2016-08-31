class AppFactory

  def self.create(resource_class)
    resource_class == Candidate ? create_candidate : create_admin
  end

  def self.create_admin(options={})
    Admin.new(options)
  end

  def self.create_candidate
    candidate = Candidate.new
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
    raise('add_confirmation_event: event_name cannot be nil') if event_name.nil? || event_name.empty?
    # puts 'starting event_name'
    new_confirmation_event = nil
    event = ConfirmationEvent.find_or_create_by!(name: event_name) do |confirmation_event|
      confirmation_event.name = event_name
      # puts 'attempting the_way_due_date'
      confirmation_event.the_way_due_date = Date.today
      confirmation_event.chs_due_date = Date.today
      # puts 'done attempting the_way_due_date'
      new_confirmation_event = confirmation_event
      # puts "new created #{confirmation_event.name} id: #{confirmation_event.id} due_date = #{confirmation_event.the_way_due_date}"
      # puts "new created #{confirmation_event.name} id: #{confirmation_event.id} due_date = #{confirmation_event.chs_due_date}"
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

  def self.add_confirmation_event_due_date(event_name)
    # puts 'starting event_name'
    new_confirmation_event = nil
    event = ConfirmationEvent.find_or_create_by!(name: event_name) do |confirmation_event|
      confirmation_event.name = event_name
      # puts 'attempting due_date'
      confirmation_event.due_date = Date.today
      # puts 'done attempting due_date'
      new_confirmation_event = confirmation_event
      # puts "new created #{confirmation_event.name} id: #{confirmation_event.id} due_date = #{confirmation_event.the_way_due_date}"
      # puts "new created #{confirmation_event.name} id: #{confirmation_event.id} due_date = #{confirmation_event.chs_due_date}"
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
    create_seed_candidate()

  end

  private

  def self.create_candidate_event(confirmation_event)
    candidate_event = CandidateEvent.new
    candidate_event.verified = false
    candidate_event.confirmation_event = confirmation_event
    candidate_event
  end

  def self.create_seed_candidate()
    Candidate.find_or_create_by!(account_name: 'vickikristoff') do |candidate|
      candidate.create_address
      candidate.parent_email_1 = 'paul@kristoffs.com'
      candidate.first_name = 'Vicki'
      candidate.last_name = 'Kristoff'
      candidate.grade = 10
      candidate.password = Rails.application.secrets.admin_password
      candidate.password_confirmation = Rails.application.secrets.admin_password
      candidate.address.street_1 = '2120 Frissell Ave.'
      candidate.address.city = 'Apex'
      candidate.address.state = 'NC'
      candidate.address.zip_code = '27502'
      self.add_candidate_events(candidate)
    end
  end

  def self.add_confirmation_events
    all_event_names = [
        # matches 20160603111604_add_parent_information_meeting.rb
        'events.parent_meeting',
        # matches 20160603161241_add_attend_retreat.rb
        'events.retreat_weekend',
        # matches 20160701175828_add_covenant_agreement.rb
        'events.sign_agreement',
        # matches 20160712191417_add_candidate_information_sheet.rb
        'events.fill_out_candidate_sheet',
        # matches 20160712191417_add_candidate_information_sheet.rb
        'events.upload_baptismal_certificate',
        # matches 20160821215148_add_sponsor_covenant.rb
        'events.upload_sponsor_covenant',
        # matches 20160825130031_add_pick_confirmation_name_event.rb
        'events.pick_confirmation_name',
        # 20160829163035_add_sponsor_candidate_confirmation_event.rb
        'events.sponsor_agreement',
        # 20160830211438_add_christian_ministry_event.rb
        'events.christian_ministry'
    ]
    all_event_names.each { |event_name| self.add_confirmation_event(I18n.t(event_name)) }
    all_event_names
  end

end
