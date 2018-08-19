# frozen_string_literal: true

#
# fillme in
#
class ExportExcelCandJob
  include SuckerPunch::Job

  # object creation
  #
  def initialize
    @sheet_mutex = Mutex.new
  end

  # called with perform_async
  #
  # === Parameters:
  #
  # * <tt>:cand_id</tt> id of candidate being processed
  # * <tt>:sheet</tt> worksheet being updated
  # * <tt>:candidate_columns</tt> columns
  # * <tt>:dir</tt> temp dir for storage
  #
  def perform(cand_id, sheet, candidate_columns, dir)
    ActiveRecord::Base.connection_pool.with_connection do
      # Rails.logger.info "Candidate.all.map{|x| x.id}=#{Candidate.all.map { |x| x.id }}"
      candidate = Candidate.find(cand_id)
      events = confirmation_events_sorted
      @sheet_mutex.synchronize do
        sheet.add_row(candidate_columns.map do |col|
          if CandidateImport.image_columns.include?(col)
            certificate_image_column(candidate, col, dir)
          elsif !CandidateImport.transient_columns.include?(col)
            get_column_value(candidate, col, events)
          end
        end)
      end
    end
  end

  # return sorted array of ConfirmationEvent by name
  #
  # === Returns:
  #
  # * <tt>Array</tt> of ConfirmationEvent
  #
  def confirmation_events_sorted
    ConfirmationEvent.order(:name)
  end

  # return the
  #
  # === Parameters:
  #
  # * <tt>:candidate</tt> Candidate:
  # * <tt>:col</tt> String: image being processed
  # * <tt>:dir</tt> String: base file path
  #
  def certificate_image_column(candidate, col, dir)
    Rails.logger.info("candidate.baptismal_certificate=#{candidate.baptismal_certificate}")
    if col.include? 'scanned_certificate'
      image = candidate.baptismal_certificate.scanned_certificate
      unless image.nil?
        export_filename = CandidateImport.image_filepath_export(candidate, dir, 'scanned_certificate', image)
        "#{image.filename}:::#{content_type(image.content_type)}:::#{export_filename}"
      end
    elsif col.include? 'retreat_verification'
      image = candidate.retreat_verification.scanned_retreat
      unless image.nil?
        export_filename = CandidateImport.image_filepath_export(candidate, dir, 'scanned_retreat', image)
        "#{image.filename}:::#{content_type(image.content_type)}:::#{export_filename}"
      end
    elsif col.include? 'scanned_eligibility'
      image = candidate.sponsor_covenant.scanned_eligibility
      unless image.nil?
        export_filename = CandidateImport.image_filepath_export(candidate, dir, 'scanned_eligibility', image)
        "#{image.filename}:::#{content_type(image.content_type)}:::#{export_filename}"
      end
    elsif col.include? 'scanned_covenant'
      image = candidate.sponsor_covenant.scanned_covenant
      unless image.nil?
        export_filename = CandidateImport.image_filepath_export(candidate, dir, 'scanned_covenant', image)
        "#{image.filename}:::#{content_type(image.content_type)}:::#{export_filename}"
      end
    end
  end

  # get content type
  #
  # === Parameters:
  #
  # * <tt>:type</tt> Candidate:
  #
  # === Returns:
  #
  # * <tt>String</tt> the content type
  #
  def content_type(type)
    return type if type.blank?
    type.split('/')[1]
  end

  # get value to put in cell
  #
  # === Parameters:
  #
  # * <tt>:candidate</tt> Candidate:
  # * <tt>:col</tt> String:
  # * <tt>:confirmation_events</tt> Array:
  #
  # === Returns:
  #
  # * <tt>Object</tt> the value from association
  #
  def get_column_value(candidate, col, confirmation_events)
    split = col.split('.')
    case split.size
    when 1
      candidate.send(col)
    when 2
      candidate_send0 = candidate.send(split[0])
      if candidate_send0.nil?
        nil
      else
        candidate_send0.send(split[1])
      end
    when 3
      if split[0] != 'candidate_events'
        candidate_send0 = candidate.send(split[0])
        if candidate_send0.nil?
          nil
        else
          candidate_send0.send(split[1]).send(split[2])
        end
      else
        confirmation_event = confirmation_events[split[1].to_i]
        cand_event = candidate.get_candidate_event(confirmation_event.name)
        cand_event.send(split[2])
      end
    else
      "Unexpected split size: #{split.size}"
    end
  end
end
