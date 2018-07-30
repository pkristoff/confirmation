# frozen_string_literal: true

require 'constants'

#
# Handles CommonCandidate tasks
#
class CommonCandidatesController < ApplicationController
  attr_accessor :resource # for testing

  # edit event_with_picture verify
  #
  # === Attributes:
  #
  # * <tt>:id</tt> Candidate id
  # * <tt>:event_name</tt> legal values
  # ** <code>:Event::Route::BAPTISMAL_CERTIFICATE</code>
  # ** <code>:Event::Route::SPONSOR_COVENANT</code>
  # ** <code>:Event::Route::RETREAT_VERIFICATION</code>
  #
  def event_with_picture_verify
    @candidate = Candidate.find(params[:id])
    @resource = @candidate
    event_name = params[:event_name]
    render_event_with_picture(false, event_name, true)
  end

  # update event_with_picture verify event
  #
  # === Attributes:
  #
  # * <tt>:id</tt> Candidate id
  # * <tt>:event_name</tt> legal values
  # ** <code>:Event::Route::BAPTISMAL_CERTIFICATE</code>
  # ** <code>:Event::Route::SPONSOR_COVENANT</code>
  # ** <code>:Event::Route::RETREAT_VERIFICATION</code>
  #
  def event_with_picture_verify_update
    @is_verify = true
    event_with_picture_update
  end

  # edit event_with_picture
  #
  # === Attributes:
  #
  # * <tt>:id</tt> Candidate id
  # * <tt>:event_name</tt> legal values
  # ** <code>:Event::Route::BAPTISMAL_CERTIFICATE</code>
  # ** <code>:Event::Route::SPONSOR_COVENANT</code>
  # ** <code>:Event::Route::RETREAT_VERIFICATION</code>
  #
  def event_with_picture
    @candidate = Candidate.find(params[:id])
    @resource = @candidate
    event_name = params[:event_name]
    render_event_with_picture(false, event_name)
  end

  # update event_with_picture
  #
  # === Attributes:
  #
  # * <tt>:commit</tt> legal values
  # ** <code>views.common.un_verify</code>
  # * <tt>:id</tt> Candidate id
  # * <tt>:event_name</tt> legal values
  # ** <code>:Event::Route::BAPTISMAL_CERTIFICATE</code>
  # ** <code>:Event::Route::SPONSOR_COVENANT</code>
  # ** <code>:Event::Route::RETREAT_VERIFICATION</code>
  #
  def event_with_picture_update
    # TODO: commonize this code
    is_unverify = params[:commit] == I18n.t('views.common.un_verify')

    candidate_id = params[:id]
    event_name = params.require(:event_name)
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
        cand_parms = params.require(:candidate).permit(baptismal_certificate_attributes: [:baptized_at_stmm,
                                                                                          :show_empty_radio,
                                                                                          :remove_certificate_picture,
                                                                                          :certificate_picture,
                                                                                          :birth_date,
                                                                                          :baptismal_date,
                                                                                          :church_name,
                                                                                          :father_first,
                                                                                          :father_middle,
                                                                                          :father_last,
                                                                                          :mother_first,
                                                                                          :mother_middle,
                                                                                          :mother_maiden,
                                                                                          :mother_last,
                                                                                          church_address_attributes: [:street_1,
                                                                                                                      :street_2,
                                                                                                                      :city,
                                                                                                                      :state,
                                                                                                                      :zip_code]],
                                                       candidate_sheet_attributes: [:first_name,
                                                                                    :middle_name,
                                                                                    :last_name])

        baptized_at_stmm = cand_parms[:baptismal_certificate_attributes][:baptized_at_stmm] == '1'
        baptismal_certificate = @candidate.baptismal_certificate
        unless baptized_at_stmm
          baptismal_certificate_params = cand_parms[:baptismal_certificate_attributes]
          if baptismal_certificate_params[:remove_certificate_picture] == 'Remove'
            baptismal_certificate.scanned_certificate = nil
          end
          setup_file_params(baptismal_certificate_params[:certificate_picture], baptismal_certificate, :scanned_certificate_attributes, params[:candidate][:baptismal_certificate_attributes])
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

  # edit candidate_sheet information
  #
  # === Attributes:
  #
  # * <tt>:id</tt> Candidate id
  #
  def candidate_sheet
    @candidate = Candidate.find(params[:id])
    @resource = @candidate
  end

  # update candidate_sheet information
  #
  # === Attributes:
  #
  # * <tt>:id</tt> Candidate id
  #
  def candidate_sheet_update
    @candidate = Candidate.find(params[:id])

    render_called = event_with_picture_update_private(CandidateSheet)

    @resource = @candidate
    render :candidate_sheet unless render_called
  end

  # edit christian_ministry information
  #
  # === Attributes:
  #
  # * <tt>:id</tt> Candidate id
  #
  def christian_ministry
    @candidate = Candidate.find(params[:id])
    @resource = @candidate
  end

  # update christian_ministry information
  #
  # === Attributes:
  #
  # * <tt>:id</tt> Candidate id
  #
  def christian_ministry_update
    @candidate = Candidate.find(params[:id])

    render_called = event_with_picture_update_private(ChristianMinistry)

    @resource = @candidate
    render :christian_ministry unless render_called
  end

  # send_pdf to browser
  #
  # === Attributes:
  #
  # * <tt>:name</tt> Name of pdf file
  #
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

  # send_image of event_with_picture
  #
  # === Attributes:
  #
  # * <tt>:id</tt> Candidate id
  # * <tt>:event_name</tt> legal values
  # ** <code>:Event::Route::BAPTISMAL_CERTIFICATE</code>
  # ** <code>:Event::Route::SPONSOR_COVENANT</code>
  # ** <code>:Event::Route::RETREAT_VERIFICATION</code>
  #
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

  # edit pick_confirmation_name information
  #
  # === Attributes:
  #
  # * <tt>:id</tt> Candidate id
  #
  def pick_confirmation_name
    @candidate = Candidate.find(params[:id])
    @resource = @candidate
  end

  # update pick_confirmation_name information
  #
  # === Attributes:
  #
  # * <tt>:id</tt> Candidate id
  #
  def pick_confirmation_name_update
    @candidate = Candidate.find(params[:id])

    render_called = event_with_picture_update_private(PickConfirmationName)

    @resource = @candidate
    render :pick_confirmation_name unless render_called
  end

  # edit sign_agreement information
  #
  # === Attributes:
  #
  # * <tt>:id</tt> Candidate id
  #
  def sign_agreement
    @is_verify = false
    @candidate = Candidate.find(params[:id])
    @resource = @candidate
  end

  # update sign_agreement information
  #
  # === Attributes:
  #
  # * <tt>:id</tt> Candidate id
  #
  def sign_agreement_update
    @candidate = Candidate.find(params[:id])
    @is_verify = false
    rendered_called = agreement_update_private(I18n.t('events.candidate_covenant_agreement'), 'signed_agreement', I18n.t('label.sign_agreement.signed_agreement'))
    return if rendered_called
    @resource = @candidate
    render :sign_agreement
  end

  # edit sign_agreement_verify information
  #
  # === Attributes:
  #
  # * <tt>:id</tt> Candidate id
  #
  def sign_agreement_verify
    @is_verify = true
    @candidate = Candidate.find(params[:id])
  end

  # update sign_agreement_verify information
  #
  # === Attributes:
  #
  # * <tt>:id</tt> Candidate id
  #
  def sign_agreement_verify_update
    is_unverify = params[:commit] == I18n.t('views.common.un_verify')

    candidate_id = params[:id]
    @candidate = Candidate.find(candidate_id)
    candidate_event = @candidate.get_candidate_event(I18n.t('events.candidate_covenant_agreement'))

    return admin_unverified_private(@candidate, candidate_event) if is_unverify

    @candidate = Candidate.find(params[:id])
    @is_verify = true
    render_called = agreement_update_private(I18n.t('events.candidate_covenant_agreement'), 'signed_agreement', I18n.t('label.sign_agreement.signed_agreement'), true)
    render :sign_agreement_verify unless render_called
  end

  # send_image scanned_eligibility image if saved
  #
  # === Attributes:
  #
  # * <tt>:id</tt> Candidate id
  #
  def upload_sponsor_eligibility_image
    @candidate = Candidate.find(params[:id])
    scanned_image = @candidate.sponsor_covenant.scanned_eligibility
    send_image(scanned_image) unless scanned_image.nil?
  end

  private

  def agreement_update_private(event_name, signed_param_name, field_name, admin_verified = false)
    candidate_event = @candidate.get_candidate_event(event_name)
    if params['candidate']
      # TODO: move logic to association instance.
      if params['candidate'][signed_param_name] == '1'
        candidate_event.completed_date = Time.zone.today if candidate_event.completed_date.nil?
        candidate_event.verified = true unless candidate_event.verified
      elsif params['candidate'][signed_param_name] == '0'
        candidate_event.completed_date = nil
        candidate_event.verified = false
      else
        redirect_to :back, alert: I18n.t('messages.unknown_parameter', name: "['candidate'][signed_param_name]: %{params['candidate'][signed_param_name]")
        return false
      end
    else
      redirect_to :back, alert: I18n.t('messages.unknown_parameter', name: 'candidate')
      return false
    end
    render_called = false
    if @candidate.update(candidate_params)
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

  def event_with_picture_update_private(clazz, admin_verified = false)
    render_called = false
    event_name = clazz.event_name

    if @candidate.update(candidate_params)

      # TODO: Move logic out of common code
      if clazz == BaptismalCertificate
        bc = @candidate.baptismal_certificate
        if bc.show_empty_radio > 1 && !bc.baptized_at_stmm? && !bc.first_comm_at_stmm?
          candidate_info_sheet_event = @candidate.get_candidate_event(I18n.t('events.candidate_information_sheet'))
          candidate_info_sheet_event.mark_completed(@candidate.validate_event_complete(CandidateSheet), CandidateSheet)
          @candidate.keep_bc_errors
          if candidate_info_sheet_event.save

          end
        end
      end

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
  # === Returns:
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
        candidates_info(confirmation_event: candidate_event.confirmation_event)
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
  # === Returns:
  #
  #
  #
  def admin_unverified_private(candidate, candidate_event)
    cand_name = "#{candidate.candidate_sheet.first_name} #{candidate.candidate_sheet.last_name}"
    candidate_event.verified = false
    if candidate_event.save
      flash['notice'] = I18n.t('messages.updated_unverified', cand_name: cand_name)
      candidates_info(confirmation_event: candidate_event.confirmation_event)
      render(:'admins/mass_edit_candidates_event')
    else
      redirect_to :back, alert: I18n.t('messages.save_failed')
    end
  end

  def render_event_with_picture(render_called, event_name, is_verify = false)
    return if render_called
    @event_with_picture_name = event_name
    @is_dev = !admin?

    @candidate_event = @candidate.get_candidate_event(I18n.t("events.#{event_name}"))
    flash[:alert] = "Internal Error: unknown event: #{event_name}: #{I18n.t("events.#{event_name}")}" if @candidate_event.nil?
    render :event_with_picture unless is_verify
    render :event_with_picture_verify if is_verify
  end

  def send_image(scanned_image)
    if scanned_image.content_type == 'image/octet-stream'
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

      pdf.each do |page_img|
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
      File.delete(pdf_file_path) if File.exist?(pdf_file_path)
      File.delete(jpg_file_path) if File.exist?(jpg_file_path)
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
    return if scanned_filename.nil?
    picture_params = ActionController::Parameters.new
    picture_params[:filename] = scanned_filename
    picture_params[:content_type] = scanned_content_type
    picture_params[:content] = scanned_content
    picture_params[:id] = scanned_image_id unless scanned_image_id.nil?
    association_params[scanned_image_attributes] = picture_params.permit(:filename, :content_type, :content, :id)
  end
end
