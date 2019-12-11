#
# AppFactory
#
class AppFactory

  #
  # create a resource_class
  #
  # === Parameters:
  #
  # * <tt>:resource_class</tt> Candidate or Admin
  #
  # === Returns:
  #
  # New instance
  #
  def self.create(resource_class)
    resource_class == Candidate ? create_candidate : create_admin
  end

  #
  # create a new Admin
  #
  # === Parameters:
  #
  # * <tt>:options</tt> options for a new Admin
  #
  # === Returns:
  #
  # New instance
  #
  def self.create_admin(options = {})
    Admin.new(options)
  end

  #
  # create a new Candidate and then add the candidate_events
  #
  # === Returns:
  #
  # New instance
  #
  def self.create_candidate
    candidate = Candidate.new
    add_candidate_events(candidate)
    candidate
  end

  #
  # add candidate events to candidate based on ConfirmationEvents
  #
  # === Parameters:
  #
  # * <tt>:candidate</tt> options for a new Admin
  #
  def self.add_candidate_events(candidate)
    raise 'Cannot add candidate_events because some already exist.' if candidate.candidate_events.size > 0
    ConfirmationEvent.all.each do |confirmation_event|
      candidate.add_candidate_event(confirmation_event)
    end
  end

  #
  # destroy candidate_event from candidates.
  #
  # === Parameters:
  #
  # * <tt>:event_name</tt> options for a new Admin
  #
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

  #
  # create a new Admin
  #
  # === Parameters:
  #
  # * <tt>:options</tt> options for a new Admin
  #
  # === Returns:
  #
  # New instance
  #
  def self.add_confirmation_event(event_name)
    raise('add_confirmation_event: event_name cannot be nil') if event_name.nil? || event_name.empty?
    # no longer an error so can migrate from a new db.
    if ConfirmationEvent.find_by(name: event_name)
      # puts("add_confirmation_event: event_name already defined: #{event_name}")
      AppFactory.revert_confirmation_event(event_name)
    end
    # puts 'starting event_name'
    new_confirmation_event = nil
    event = ConfirmationEvent.find_or_create_by!(name: event_name) do |confirmation_event|
      confirmation_event.name = event_name
      # puts 'attempting the_way_due_date'
      today = Time.zone.today
      confirmation_event.the_way_due_date = today
      confirmation_event.chs_due_date = today
      # puts 'done attempting the_way_due_date'
      new_confirmation_event = confirmation_event
      # puts "new created #{confirmation_event.name} id: #{confirmation_event.id} due_date = #{confirmation_event.the_way_due_date}"
      # puts "new created #{confirmation_event.name} id: #{confirmation_event.id} due_date = #{confirmation_event.chs_due_date}"
    end
    unless new_confirmation_event.nil?
      # puts 'adding to candidates'
      Candidate.all.each do |candidate|
        candidate.add_candidate_event(new_confirmation_event)
        # puts "adding to candidate: #{candidate.account_name}  candidate=#{candidate}"
        candidate.save
      end
    end
    # puts 'ending event_name'
    event
  end

  # create or update ConfirmationEvent.  Update all candidates with new ConfirmationEvent
  #
  # === Parameters:
  #
  # * <tt>:event_name</tt> ConfirmationEvent name
  #
  # === Returns:
  #
  # CandidateEvent
  #
  def self.add_confirmation_event_due_date(event_name)
    # puts 'starting event_name'
    new_confirmation_event = nil
    event = ConfirmationEvent.find_or_create_by!(name: event_name) do |confirmation_event|
      confirmation_event.name = event_name
      # puts 'attempting due_date'
      confirmation_event.due_date = Time.zone.today
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

  # create or find the Admin - reseting password.  Then create the seed
  #
  def self.generate_seed(contact_name = 'Vicki Kristoff', contact_phone = '919-249-5629', email = 'stmm.confirmation@kristoffs.com')
    Admin.find_or_create_by!(email: email) do |admin|
      admin.name = Rails.application.secrets.admin_name
      admin.contact_name = contact_name
      admin.contact_phone = contact_phone
      admin.email = email
      admin.password = Rails.application.secrets.admin_password
      admin.password_confirmation = Rails.application.secrets.admin_password
    end
    create_seed_candidate
  end

  private

  # Create CandidateEvent based on confirmation_event
  #
  # === Parameters:
  #
  # * <tt>:confirmation_event</tt> ConfirmationEvent
  #
  # === Returns:
  #
  # CandidateEvent
  #
  def self.create_candidate_event(confirmation_event)
    candidate_event = CandidateEvent.new
    candidate_event.verified = false
    candidate_event.confirmation_event = confirmation_event
    candidate_event
  end

  # Create seed Candidate
  #
  # === Returns:
  #
  # Candidate: new instance
  #
  def self.create_seed_candidate
    Candidate.find_or_create_by!(account_name: 'vickikristoff') do |candidate|
      candidate.password = Event::Other::INITIAL_PASSWORD
      candidate.password_confirmation = Event::Other::INITIAL_PASSWORD
      # Rails 5.2 - create would have errored about not doing a save on parent.
      candidate.build_candidate_sheet if candidate.candidate_sheet.nil?
      candidate.candidate_sheet.parent_email_1 = 'stmm.confirmation@kristoffs.com'
      candidate.candidate_sheet.first_name = 'Vicki'
      candidate.candidate_sheet.middle_name = 'Anne'
      candidate.candidate_sheet.last_name = 'Kristoff'
      candidate.candidate_sheet.grade = 10
      candidate.candidate_sheet.address.street_1 = '2120 Frissell Ave.'
      candidate.candidate_sheet.address.city = 'Apex'
      candidate.candidate_sheet.address.state = 'NC'
      candidate.candidate_sheet.address.zip_code = '27502'
      self.add_candidate_events(candidate)
    end
  end

  # clear confirmation events and Create ConfirmationEvents
  #
  # === Returns:
  #
  # Array: ConfirmationEvent name
  #
  def self.add_confirmation_events
    all_confirmation_event_names = ConfirmationEvent.all.map { |ce| ce.name }
    all_confirmation_event_names.each do |ce_name|
      AppFactory.revert_confirmation_event(ce_name)
    end
    every_event_names = all_i18n_confirmation_event_names
    every_event_names.each { |event_name| self.add_confirmation_event(event_name) }
    every_event_names
  end

  # return a list of the I18n ConfirmationEvent names
  #
  # === Returns:
  #
  # CandidateEvent
  #
  def self.all_i18n_confirmation_event_names
    [
      # matches 20160603111604_add_parent_information_meeting.rb
      Candidate.parent_meeting_event_name,
      # matches 20160603161241_add_attend_retreat.rb
      RetreatVerification.event_name,
      # matches 20160701175828_add_covenant_agreement.rb
      Candidate.covenant_agreement_event_name,
      # matches 20160712191417_add_candidate_information_sheet.rb
      CandidateSheet.event_name,
      # matches 20160712191417_add_candidate_information_sheet.rb
      BaptismalCertificate.event_name,
      # matches 20160821215148_add_sponsor_covenant.rb
      SponsorCovenant.event_name,
      # matches 20160825130031_add_pick_confirmation_name_event.rb
      PickConfirmationName.event_name,
      # 20160830211438_add_christian_ministry_event.rb
      ChristianMinistry.event_name
    ]
  end

end
