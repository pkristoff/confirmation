require 'constants'

class CommonCandidatesController < ApplicationController

  attr_accessor :resource # for testing

  def event_with_picture_verify
    @candidate = Candidate.find(params[:id])
    @resource = @candidate
    event_name = params[:event_name]
    render_event_with_picture(false, event_name, true)
  end

  def event_with_picture_verify_update
    @is_verify = true
    event_with_picture_update
  end

  def event_with_picture
    @candidate = Candidate.find(params[:id])
    @resource = @candidate
    event_name = params[:event_name]
    render_event_with_picture(false, event_name)
  end

  def event_with_picture_update
    # TODO: commonize this code
    is_unverify = params[:commit] == I18n.t('views.common.un_verify')

    candidate_id = params[:id]
    event_name = params[:event_name]
    @candidate = Candidate.find(candidate_id)
    candidate_event = @candidate.get_candidate_event(I18n.t("events.#{event_name}"))

    return admin_unverified_private(@candidate, candidate_event) if is_unverify

    is_verify = @is_verify.nil? ? false : @is_verify
    render_called = false
    if params['candidate']
      case event_name.to_sym
      when Event::Route::SPONSOR_COVENANT
        sponsor_covenant = @candidate.sponsor_covenant
        sponsor_covenant_params = params[:candidate][:sponsor_covenant_attributes]
        if sponsor_covenant_params[:remove_sponsor_covenant_picture] == 'Remove'
          sponsor_covenant.scanned_covenant = nil
          else
          setup_file_params(sponsor_covenant_params[:sponsor_covenant_picture], sponsor_covenant, :scanned_covenant_attributes, sponsor_covenant_params)
        end
        if sponsor_covenant_params[:remove_sponsor_eligibility_picture] == 'Remove'
          sponsor_covenant.scanned_eligibility = nil
          else
          setup_file_params(sponsor_covenant_params[:sponsor_eligibility_picture], sponsor_covenant, :scanned_eligibility_attributes, sponsor_covenant_params)
        end

        render_called = event_with_picture_update_private(SponsorCovenant, is_verify)

      when Event::Route::BAPTISMAL_CERTIFICATE
        baptized_at_stmm = params[:candidate]['baptized_at_stmm'] == '1'
        baptismal_certificate = @candidate.baptismal_certificate
        unless baptized_at_stmm
          baptismal_certificate_params = params[:candidate][:baptismal_certificate_attributes]
          if baptismal_certificate_params[:remove_certificate_picture] == 'Remove'
            baptismal_certificate.scanned_certificate = nil
          end
          setup_file_params(baptismal_certificate_params[:certificate_picture], baptismal_certificate, :scanned_certificate_attributes, baptismal_certificate_params)
        end

        render_called = event_with_picture_update_private(BaptismalCertificate, is_verify)

      when Event::Route::RETREAT_VERIFICATION
        retreat_verification = @candidate.retreat_verification
        retreat_verification_params = params[:candidate][:retreat_verification_attributes]
        if retreat_verification_params[:remove_retreat_verification_picture] == 'Remove'
          retreat_verification.scanned_retreat = nil
        end
        setup_file_params(retreat_verification_params[:retreat_verification_picture], retreat_verification, :scanned_retreat_attributes, retreat_verification_params)

        render_called = event_with_picture_update_private(RetreatVerification, is_verify)
      else
        flash[:alert] = "Unknown event_name: #{event_name}"
      end
    else
      flash[:alert] = I18n.t('messages.unknown_parameter', name: 'candidate')
    end
    @resource = @candidate
    render_event_with_picture(render_called, event_name, is_verify)

  end

  def candidate_sheet
    @candidate = Candidate.find(params[:id])
    @resource = @candidate
  end

  def candidate_sheet_update
    @candidate = Candidate.find(params[:id])

    render_called = event_with_picture_update_private(CandidateSheet)

    @resource = @candidate
    render :candidate_sheet unless render_called

  end

  def christian_ministry
    @candidate = Candidate.find(params[:id])
    @resource = @candidate
  end

  def christian_ministry_update
    @candidate = Candidate.find(params[:id])

    render_called = event_with_picture_update_private(ChristianMinistry)

    @resource = @candidate
    render :christian_ministry unless render_called

  end

  def download_document
    doc_name = Event::Document::MAPPING[params[:name].to_sym]
    pdf = File.new("public/documents/#{doc_name}")
    pdf_data = File.read(pdf.path)
    begin
      send_data(pdf_data, type: 'application/pdf', filename: doc_name)
    ensure
      pdf.close
    end

  end

  def event_with_picture_image
    @candidate = Candidate.find(params[:id])
    scanned_image = nil
    case params[:event_name].to_sym
    when Event::Route::BAPTISMAL_CERTIFICATE
      scanned_image = @candidate.baptismal_certificate.scanned_certificate
    when Event::Route::SPONSOR_COVENANT
      scanned_image = @candidate.sponsor_covenant.scanned_covenant
    when Event::Route::RETREAT_VERIFICATION
      scanned_image = @candidate.retreat_verification.scanned_retreat
    else
      flash['alert'] = "Unknown event_name #{params[:event_name]}"
    end
    if scanned_image.nil?
    else
      send_image(scanned_image)
    end
  end

  def pick_confirmation_name
    @candidate = Candidate.find(params[:id])
    @resource = @candidate
  end

  def pick_confirmation_name_update
    @candidate = Candidate.find(params[:id])

    render_called = event_with_picture_update_private(PickConfirmationName)

    @resource = @candidate
    render :pick_confirmation_name unless render_called
  end

  def sign_agreement
    @is_verify = false
    @candidate = Candidate.find(params[:id])
    @resource = @candidate
  end

  def sign_agreement_update
    @candidate = Candidate.find(params[:id])
    @is_verify = false
    rendered_called = agreement_update_private(I18n.t('events.candidate_covenant_agreement'), 'signed_agreement', I18n.t('label.sign_agreement.signed_agreement'))
    unless rendered_called
      # @candidate = Candidate.find(params[:id])
      @resource = @candidate
      render :sign_agreement
    end
  end

  def sign_agreement_verify
    @is_verify = true
    @candidate = Candidate.find(params[:id])
  end

  def sign_agreement_verify_update
    is_unverify = params[:commit] == I18n.t('views.common.un_verify')

    candidate_id = params[:id]
    event_name = params[:event_name]
    @candidate = Candidate.find(candidate_id)
    candidate_event = @candidate.get_candidate_event(I18n.t("events.candidate_covenant_agreement"))

    return admin_unverified_private(@candidate, candidate_event) if is_unverify

    @candidate = Candidate.find(params[:id])
    @is_verify = true
    render_called = agreement_update_private(I18n.t('events.candidate_covenant_agreement'), 'signed_agreement', I18n.t('label.sign_agreement.signed_agreement'), true)
    render :sign_agreement_verify unless render_called
  end

  def agreement_update_private(event_name, signed_param_name, field_name, admin_verified = false)
    candidate_event = @candidate.get_candidate_event(event_name)
    if params['candidate']
      # TODO move logic to association instance.
      if params['candidate'][signed_param_name] === '1'
        candidate_event.completed_date = Date.today if candidate_event.completed_date.nil?
        candidate_event.verified = true unless candidate_event.verified
      else
        if params['candidate'][signed_param_name] === '0'
          candidate_event.completed_date = nil
          candidate_event.verified = false
        else
          redirect_to :back, alert: I18n.t('messages.unknown_parameter', name: "['candidate'][signed_param_name]: %{params['candidate'][signed_param_name]")
          return false
        end
      end
    else
      redirect_to :back, alert: I18n.t('messages.unknown_parameter', name: 'candidate')
      return false
    end
    render_called = false
    if @candidate.update_attributes(candidate_params)
      # Make up a validation error
      @candidate.errors.add :base, I18n.t('messages.signed_agreement_val', field_name: field_name) if candidate_event.completed_date.nil?
      if candidate_event.save
        if admin_verified
          render_called = admin_verified_private(candidate_event, event_name)
        else
          flash['notice'] = I18n.t('messages.updated', cand_name: "#{@candidate.candidate_sheet.first_name} #{@candidate.candidate_sheet.last_name}")
        end
      else
        flash['alert'] = "Save of #{event_name} failed"
      end
      render_called
    else
      redirect_to :back, alert: I18n.t('messages.save_failed')
      true
    end
  end

  def sponsor_agreement
    @candidate = Candidate.find(params[:id])
    @resource = @candidate
  end

  def sponsor_agreement_update
    @candidate = Candidate.find(params[:id])
    agreement_update_private(I18n.t('events.sponsor_agreement'), 'sponsor_agreement', I18n.t('label.sponsor_agreement.sponsor_agreement'))
    @resource = @candidate
    render :sponsor_agreement
  end

  def upload_sponsor_eligibility_image
    @candidate = Candidate.find(params[:id])
    scanned_image = @candidate.sponsor_covenant.scanned_eligibility
    send_image(scanned_image) unless scanned_image.nil?
  end

  private

  def event_with_picture_update_private(clazz, admin_verified = false)
    render_called = false
    event_name = clazz.event_name

    if @candidate.update_attributes(candidate_params)
      candidate_event = @candidate.get_candidate_event(event_name)
      candidate_event.mark_completed(@candidate.validate_event_complete(clazz), clazz)
      if candidate_event.save
        # @resource = @candidate
        if admin_verified
          render_called = admin_verified_private(candidate_event, event_name)
        else
          flash['notice'] = I18n.t('messages.updated', cand_name: "#{@candidate.candidate_sheet.first_name} #{@candidate.candidate_sheet.last_name}")
        end
      else
        flash['alert'] = "Save of #{event_name} failed"
      end
    else
      flash['alert'] = 'Update_attributes fails'
    end
    render_called
  end

  # attempts to set verify on CandidateEvent and render
  # mass_edit_candidates_event
  #
  # === Parameters:
  #
  # * <tt>:candidate_event</tt> CandidateEvent
  # * <tt>:event_name</tt> ConfirmationEvent name
  #
  # === Return:
  #
  # Boolean:  whether render was called
  #
  def admin_verified_private(candidate_event, event_name)
    render_called = false
    cand_name = "#{@candidate.candidate_sheet.first_name} #{@candidate.candidate_sheet.last_name}"
    if @candidate.errors.any?
      flash['notice'] = I18n.t('messages.updated_not_verified', cand_name: cand_name)
    else
      candidate_event.verified = true
      if candidate_event.save
        flash['notice'] = I18n.t('messages.updated_verified', cand_name: cand_name)
        render_called = true
        set_candidates(confirmation_event: candidate_event.confirmation_event)
        render(:'admins/mass_edit_candidates_event')
      else
        flash['alert'] = "Save of #{event_name} failed"
      end
    end
    render_called
  end

  # attempts to set verify on CandidateEvent and render
  # mass_edit_candidates_event
  #
  # === Parameters:
  #
  # * <tt>:candidate_event</tt> CandidateEvent
  # * <tt>:event_name</tt> ConfirmationEvent name
  #
  # === Return:
  #
  #
  #
  def admin_unverified_private(candidate, candidate_event)
    cand_name = "#{candidate.candidate_sheet.first_name} #{candidate.candidate_sheet.last_name}"
    candidate_event.verified = false
    if candidate_event.save
      flash['notice'] = I18n.t('messages.updated_unverified', cand_name: cand_name)
      set_candidates(confirmation_event: candidate_event.confirmation_event)
      render(:'admins/mass_edit_candidates_event')
    else
      redirect_to :back, alert: I18n.t('messages.save_failed')
    end
  end

  def render_event_with_picture(render_called, event_name, is_verify = false)
    unless render_called
      @event_with_picture_name = event_name
      @is_dev = !admin?

      @candidate_event = @candidate.get_candidate_event(I18n.t("events.#{event_name}"))
      flash[:alert] = "Internal Error: unknown event: #{event_name}: #{I18n.t("events.#{event_name}")}" if @candidate_event.nil?
      render :event_with_picture unless is_verify
      render :event_with_picture_verify if is_verify
    end
  end

  def send_image(scanned_image)
    if scanned_image.content_type === 'image/octet-stream'
      send_octet(scanned_image)
    else
      conts = scanned_image.content
      c_type = scanned_image.content_type
      send_data conts,
                type: c_type,
                disposition: 'inline'
    end
  end

  def send_octet(scanned_image)
    image_file_path = "tmp/#{scanned_image.filename}"
    jpg_file_path = image_file_path + '.jpg'
    pdf_file_path = image_file_path + '.pdf'
    File.open(pdf_file_path, 'wb') do |f|
      f.write(scanned_image.content)
    end
    begin

      pdf = Magick::ImageList.new(pdf_file_path)

      pdf.each_with_index do |page_img, i|
        page_img.write jpg_file_path
      end
      conts = nil
      File.open(jpg_file_path, 'rb') do |f|
        conts = f.read
      end

      send_data conts,
                type: 'image/jpg',
                disposition: 'inline'
    ensure
      File.delete(pdf_file_path) if File.exists?(pdf_file_path)
      File.delete(jpg_file_path) if File.exists?(jpg_file_path)
    end
  end

  def setup_file_params(file, association, scanned_image_attributes, association_params)

    scanned_filename = nil
    scanned_content_type = nil
    scanned_content = nil
    scanned_image_id = nil
    case scanned_image_attributes
    when :scanned_certificate_attributes
      unless file.nil? && association.scanned_certificate.nil?
        scanned_image_id = association.scanned_certificate_id
        scanned_filename = file ? File.basename(file.original_filename) : association.scanned_certificate.filename
        scanned_content_type = file ? file.content_type : association.scanned_certificate.content_type
        scanned_content = file ? file.read : association.scanned_certificate.content
      end
    when :scanned_retreat_attributes
      unless file.nil? && association.scanned_retreat.nil?
        scanned_image_id = association.scanned_retreat_id
        scanned_filename = file ? File.basename(file.original_filename) : association.scanned_retreat.filename
        scanned_content_type = file ? file.content_type : association.scanned_retreat.content_type
        scanned_content = file ? file.read : association.scanned_retreat.content
      end
    when :scanned_eligibility_attributes
      unless file.nil? && association.scanned_eligibility.nil?
        scanned_image_id = association.scanned_eligibility_id
        scanned_filename = file ? File.basename(file.original_filename) : association.scanned_eligibility.filename
        scanned_content_type = file ? file.content_type : association.scanned_eligibility.content_type
        scanned_content = file ? file.read : association.scanned_eligibility.content
      end
    when :scanned_covenant_attributes
      unless file.nil? && association.scanned_covenant.nil?
        scanned_image_id = association.scanned_covenant_id
        scanned_filename = file ? File.basename(file.original_filename) : association.scanned_covenant.filename
        scanned_content_type = file ? file.content_type : association.scanned_covenant.content_type
        scanned_content = file ? file.read : association.scanned_covenant.content
      end
    else
      raise "Unknown scanned_image_attributes #{scanned_image_attributes}"
    end
    unless scanned_filename.nil?
      picture_params = ActionController::Parameters.new
      association_params[scanned_image_attributes] = picture_params
      picture_params[:filename] = scanned_filename
      picture_params[:content_type] = scanned_content_type
      picture_params[:content] = scanned_content
      picture_params[:id] = scanned_image_id unless scanned_image_id.nil?
    end
  end

end