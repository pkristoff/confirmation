# frozen_string_literal: true

#
# This was created in an attempt to keep DB objects from being created to generate
# the sorting_candidate_selection pane.
#
# Each instance represents a row in _sorting_candidate_selection.html.erb
#
# === Parameters:
#
# * <tt>:cand_info</tt> Candidate information shown in the sorting table.
# * <tt>:cand_event_info</tt> A hash that has the information necessary to generate the status of each candidate event.
# * <tt>:candidate_event</tt> The candidate event information being edited in mass_edit_candidates_event.html.erb
#
class PluckCan
  # instantiation
  #
  # === Parameters:
  #
  # * <tt>:cand_info</tt> Candidate information shown in the sorting table.
  # * <tt>:cand_event_info</tt> A hash that has the information necessary to generate the status of each candidate event
  # * <tt>:candidate_event</tt> The candidate event information being edited in mass_edit_candidates_event.html.erb
  #
  # === Returns:
  #
  # * <tt>Array</tt> of PluckCan
  #
  def initialize(cand_info, cand_event_info, candidate_event = nil)
    @cand_info = cand_info
    @cand_event_info = cand_event_info
    @candidate_event = candidate_event
  end

  # Returns a ScannedImage
  #
  # === Parameters:
  #
  # * <tt>:scanned_image</tt>
  #
  # === Returns:
  #
  # * <tt>ScannedImage</tt>
  #
  def self.image(scanned_image)
    return nil if scanned_image.nil?

    id = scanned_image.id

    arr = ScannedImage.where(id: id).pluck(Arel.sql('length(content)'))
    image_s = arr[0]
    if image_s > 30_000_000 # bytes
      ans = ScannedImage.where(id: id).pluck(:id, :filename, :content_type)[0]
      ans.push(nil)
    else
      ScannedImage.where(id: id).pluck(:id, :filename, :content_type, :content)[0]
    end
  end

  # Returns the image filename
  #
  # === Parameters:
  #
  # * <tt>:pluck_image</tt> An Array of an image info
  #
  # === Returns:
  #
  # * <tt>Number</tt> representing image id
  #
  def self.image_id(pluck_image)
    pluck_image[0]
  end

  # Returns the image filename
  #
  # === Parameters:
  #
  # * <tt>:pluck_image</tt> An Array of an image info
  #
  # === Returns:
  #
  # * <tt>String</tt> representing image filename
  #
  def self.image_filename(pluck_image)
    pluck_image[2]
  end

  # Returns the image type
  #
  # === Parameters:
  #
  # * <tt>:pluck_image</tt> An Array of an image info
  #
  # === Returns:
  #
  # * <tt>Binary</tt> representing image type
  #
  def self.image_content_type(pluck_image)
    pluck_image[2]
  end

  # Returns the image content
  #
  # === Parameters:
  #
  # * <tt>:pluck_image</tt> An Array of an image
  #
  # === Returns:
  #
  # * <tt>Binary</tt> representing image content
  #
  def self.image_content(pluck_image)
    pluck_image[3]
  end

  # Calculate status of candidate_event
  #
  # === Parameters:
  #
  # * <tt>:args</tt> A hash of arguments
  #
  # === Returns:
  #
  # * <tt>Array</tt> of PluckCan
  #
  def self.pluck_candidates(args = {})
    args = { event_id: nil }.merge(args)
    candidate_events = pluck_cand_events
    Rails.logger.info("candidate_events=#{candidate_events}")
    join = Candidate.joins(:candidate_sheet)
    sorted = args[:sort].nil? ? join : join.order(Arel.sql("#{args[:sort]} #{args[:direction]}"))
    sorted.pluck(:id,
                 :account_name,
                 :confirmed_at,
                 :encrypted_password,
                 :last_name,
                 :first_name,
                 :grade,
                 :program_year,
                 :attending).map do |cand_info|
      candidate_id = cand_info[0]
      Rails.logger.info("cand_info=#{cand_info}")
      Rails.logger.info("account_name=#{cand_info[1]}")
      Rails.logger.info("candidate_events=#{candidate_events[candidate_id]}")
      event = candidate_events[candidate_id].find do |cand_event_for_cand|
        cand_event_for_cand[1] == args[:event_id]
      end
      PluckCan.new(cand_info, candidate_events, event)
    end
  end

  # return first name based on pluck_bap_candidates
  #
  # === Returns:
  #
  # * <tt>String</tt>first name
  #
  def bap_first_name
    @cand_info[1]
  end

  # return middle name based on pluck_bap_candidates
  #
  # === Returns:
  #
  # * <tt>String</tt>middle name
  #
  def bap_middle_name
    @cand_info[2]
  end

  # return last name based on pluck_bap_candidates
  #
  # === Returns:
  #
  # * <tt>String</tt>last name
  #
  def bap_last_name
    @cand_info[3]
  end

  # return baptismal certificate id based on pluck_bap_candidates
  #
  # === Returns:
  #
  # * <tt>Integer</tt>baptismal certificate id
  #
  def bap_bc_id
    @cand_info[4]
  end

  # Gather baptismal certificate info
  #
  # === Returns:
  #
  # * <tt>Array</tt> of baptismal certificate information
  #
  def self.pluck_bap_candidates
    candidate_events = pluck_cand_events
    Rails.logger.info("candidate_events=#{candidate_events}")
    join = Candidate.joins(:candidate_sheet)
    sorted = join.order('account_name asc')
    sorted.pluck(:id, :first_name, :middle_name, :last_name, :baptismal_certificate_id).map do |cand_info|
      candidate_id = cand_info[0]
      event = candidate_events[candidate_id].find do |cand_event_for_cand|
        cand_event_for_cand[3] == BaptismalCertificate.event_key
      end
      accept = if event[5].nil?
                 false
               else
                 baptismal_certificate = BaptismalCertificate.find_by(id: cand_info[4])
                 if baptismal_certificate.baptized_at_home_parish
                   false
                 else
                   true
                 end
               end
      PluckCan.new(cand_info, candidate_events, event) if accept
    end
  end

  # Gather candidate_events information
  #
  # === Returns:
  #
  # * <tt>Array</tt> of candidate_event information
  #
  def self.pluck_cand_events
    cand_event_info = {}
    ToDo.joins(:confirmation_event, :candidate_event).pluck(:candidate_id,
                                                            :confirmation_event_id,
                                                            :candidate_event_id,
                                                            :event_key,
                                                            :verified,
                                                            :completed_date,
                                                            :the_way_due_date,
                                                            :chs_due_date).each do |info|
      cand_info = cand_event_info[info[0]]
      if cand_info.nil?
        cand_info = []
        cand_event_info[info[0]] = cand_info
      end
      cand_info << info
    end
    cand_event_info
  end

  # Calculate status of candidate_event
  #
  # === Parameters:
  #
  # * <tt>:cand_id</tt> Candidate id.
  # * <tt>:event_key</tt> DB name.
  # * <tt>:attending</tt> The way or catholic hs.
  #
  def status(cand_id, event_key, _attending)
    event_info = @cand_event_info[cand_id].find do |cand_event_for_cand|
      cand_event_for_cand[3] == event_key
    end
    CandidateEvent.status(event_info[6],
                          event_info[5],
                          event_info[4])
  end

  # Get Confirmation event id.
  #
  # === Parameters:
  #
  # * <tt>:cand_id</tt> Candidate id.
  # * <tt>:event_key</tt> candidate event database key.
  #
  def conf_event_id(cand_id, event_key)
    event_info = @cand_event_info[cand_id].find do |cand_event_for_cand|
      cand_event_for_cand[3] == event_key
    end
    event_info[1]
  end

  # candidate_event_id
  #
  # === Returns:
  #
  # * <tt>String</tt>
  #
  def candidate_event_id
    @candidate_event[3]
  end

  # verified
  #
  # === Returns:
  #
  # * <tt>Boolean</tt>
  #
  def verified
    @candidate_event[4]
  end

  # completed_date
  #
  # === Returns:
  #
  # * <tt>Date</tt>
  #
  def completed_date
    @candidate_event[5]
  end

  # id
  #
  # === Returns:
  #
  # * <tt>String</tt>
  #
  def id
    @cand_info[0]
  end

  # account_name
  #
  # === Returns:
  #
  # * <tt>String</tt>
  #
  def account_name
    @cand_info[1]
  end

  # confirmed?
  #
  # === Returns:
  #
  # * <tt>Boolean</tt>
  #
  def confirmed?
    @cand_info[2] ? true : false
  end

  # password_changed
  #
  # === Returns:
  #
  # * <tt>Boolean</tt>
  #
  def password_changed
    encrypted_password = @cand_info[3]
    # Copied from database_authenticatable.rb - valid_Password?
    !Devise::Encryptor.compare(Candidate, encrypted_password, Event::Other::INITIAL_PASSWORD)
  end

  # last_name
  #
  # === Returns:
  #
  # * <tt>String</tt>
  #
  def last_name
    @cand_info[4]
  end

  # first_name
  #
  # === Returns:
  #
  # * <tt>String</tt>
  #
  def first_name
    @cand_info[5]
  end

  # grade
  #
  # === Returns:
  #
  # * <tt>Integer</tt> 8-12
  #
  def grade
    @cand_info[6]
  end

  # program_year
  #
  # === Returns:
  #
  # * <tt>Integer</tt> 1 or 2
  #
  def program_year
    @cand_info[7]
  end

  # attending
  #
  # === Returns:
  #
  # * <tt>Symbol</tt> :attending
  #
  def attending
    @cand_info[8]
  end
end
