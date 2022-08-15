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
  # * <tt>:event_route</tt> legal values
  # ** <code>:Event::Route::BAPTISMAL_CERTIFICATE</code>
  # ** <code>:Event::Route::SPONSOR_COVENANT</code>
  # ** <code>:Event::Route::RETREAT_VERIFICATION</code>
  #
  def event_with_picture_verify
    @candidate = Candidate.find(params[:id])
    @resource = @candidate
    event_key = params[:event_route]
    render_event_with_picture(false, event_key, is_verify: true)
  end

  # update event_with_picture verify event
  #
  # === Attributes:
  #
  # * <tt>:id</tt> Candidate id
  # * <tt>:event_route</tt> legal values
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
  # * <tt>:event_route</tt> legal values
  # ** <code>:Event::Route::BAPTISMAL_CERTIFICATE</code>
  # ** <code>:Event::Route::SPONSOR_COVENANT</code>
  # ** <code>:Event::Route::RETREAT_VERIFICATION</code>
  #
  def event_with_picture
    @candidate = Candidate.find(params[:id])
    @resource = @candidate
    event_route = params[:event_route]
    render_event_with_picture(false, event_route)
  end

  # update event_with_picture
  #
  # === Attributes:
  #
  # * <tt>:commit</tt> legal values
  # ** <code>views.common.un_verify</code>
  # * <tt>:id</tt> Candidate id
  # * <tt>:event_route</tt> legal values
  # ** <code>:Event::Route::BAPTISMAL_CERTIFICATE</code>
  # ** <code>:Event::Route::SPONSOR_COVENANT</code>
  # ** <code>:Event::Route::RETREAT_VERIFICATION</code>
  #
  def event_with_picture_update
    # TODO: commonize this code
    is_unverify = params[:commit] == I18n.t('views.common.un_verify')

    candidate_id = params[:id]
    event_route = params.require('event_route')
    event_key = Candidate.event_key_from_route(event_route)
    @candidate = Candidate.find(candidate_id)
    candidate_event = @candidate.get_candidate_event(event_key)

    return admin_unverified_private(@candidate, candidate_event) if is_unverify

    is_verify = @is_verify.nil? ? false : @is_verify
    render_called = false
    if params['candidate']
      case event_route.to_sym

      when Event::Route::SPONSOR_COVENANT
        render_called = sponsor_covenant(is_verify)

      when Event::Route::SPONSOR_ELIGIBILITY
        render_called = sponsor_eligibility(is_verify)

      when Event::Route::BAPTISMAL_CERTIFICATE
        render_called = baptismal_certificate(is_verify)

      when Event::Route::RETREAT_VERIFICATION
        render_called = retreat_verification(is_verify)
      else
        flash[:alert] = "Unknown event_route: #{event_route}"
      end
    else
      flash[:alert] = I18n.t('messages.unknown_parameter', name: 'candidate')
    end
    @resource = @candidate
    render_event_with_picture(render_called, event_route, is_verify: is_verify)
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
  # * <tt>:event_route</tt> legal values
  # ** <code>:Event::Route::BAPTISMAL_CERTIFICATE</code>
  # ** <code>:Event::Route::SPONSOR_COVENANT</code>
  # ** <code>:Event::Route::RETREAT_VERIFICATION</code>
  #
  def event_with_picture_image
    @candidate = Candidate.find(params[:id])
    scanned_image = nil
    case params[:event_route].to_sym
    when Event::Route::BAPTISMAL_CERTIFICATE
      other = params[:is_other]
      other = true if params[:is_other] == 'true'
      other = false if params[:is_other] == 'false'
      # other = params[:is_other] == 'true' ? true : params[:is_other] == 'false' ? false : params[:is_other]
      scanned_image = @candidate.baptismal_certificate.scanned_image unless other
      scanned_image = @candidate.baptismal_certificate.scanned_prof_image if other
    when Event::Route::SPONSOR_COVENANT
      scanned_image = @candidate.sponsor_covenant.scanned_image
    when Event::Route::SPONSOR_ELIGIBILITY
      scanned_image = @candidate.sponsor_eligibility.scanned_image
    when Event::Route::RETREAT_VERIFICATION
      scanned_image = @candidate.retreat_verification.scanned_image
    else
      flash['alert'] = "Unknown event_route #{params[:event_route]}"
    end
    send_image(scanned_image) unless scanned_image.nil?
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
    rendered_called = agreement_update_private(
      Candidate.covenant_agreement_event_key,
      'signed_agreement',
      I18n.t('label.sign_agreement.signed_agreement')
    )
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
    candidate_event = @candidate.get_candidate_event(Candidate.covenant_agreement_event_key)

    return admin_unverified_private(@candidate, candidate_event) if is_unverify

    @candidate = Candidate.find(params[:id])
    @is_verify = true
    render_called = agreement_update_private(Candidate.covenant_agreement_event_key,
                                             'signed_agreement',
                                             I18n.t('label.sign_agreement.signed_agreement'),
                                             admin_verified: true)
    render :sign_agreement_verify unless render_called
  end

  private

  def agreement_update_private(event_key, signed_param_name, field_name, admin_verified: false)
    candidate_event = @candidate.get_candidate_event(event_key)
    if params['candidate']
      # TODO: move logic to association instance.
      case params['candidate'][signed_param_name]
      when '1'
        candidate_event.completed_date = Time.zone.today if candidate_event.completed_date.nil?
        candidate_event.verified = true unless candidate_event.verified
      when '0'
        candidate_event.completed_date = nil
        candidate_event.verified = false
      else
        unknown_parm_name = "['candidate'][signed_param_name]: %{params['candidate'][signed_param_name]"
        redirect_to :back, alert: I18n.t('messages.unknown_parameter', name: unknown_parm_name)
        return false
      end
    else
      redirect_to :back, alert: I18n.t('messages.unknown_parameter', name: 'candidate')
      return false
    end
    render_called = false
    if @candidate.update(candidate_params)
      # Make up a validation error
      event_complete = candidate_event.completed_date.nil?
      @candidate.errors.add :base, I18n.t('messages.signed_agreement_val', field_name: field_name) if event_complete
      if candidate_event.save
        if admin_verified
          render_called = admin_verified_private(candidate_event, event_key)
        else
          flash['notice'] = I18n.t(
            'messages.updated',
            cand_name: "#{@candidate.candidate_sheet.first_name} #{@candidate.candidate_sheet.last_name}"
          )
        end
      else
        flash['alert'] = "Save of #{event_key} failed"
      end
      render_called
    else
      redirect_to :back, alert: I18n.t('messages.save_failed')
      true
    end
  end

  # attempts to set verify on CandidateEvent and render
  # mass_edit_candidates_event
  #
  # === Parameters:
  #
  # * <tt>:candidate_event</tt> CandidateEvent
  # * <tt>:event_key</tt> ConfirmationEvent name
  #
  # === Returns:
  #
  # Boolean:  whether render was called
  #
  def admin_verified_private(candidate_event, event_key)
    render_called = false
    cand_name = @candidate.first_last_name
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
        flash['alert'] = "Save of #{event_key} failed"
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
  # * <tt>:event_key</tt> ConfirmationEvent name
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

  def render_event_with_picture(render_called, event_route, is_verify: false)
    return if render_called

    @event_with_picture_route = event_route.to_sym
    @is_dev = !admin?

    @candidate_event = @candidate.get_candidate_event(Candidate.event_key_from_route(event_route))
    flash[:alert] = "Internal Error: unknown event: #{event_route}" if @candidate_event.nil?
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
    jpg_file_path = "#{image_file_path}.jpg"
    pdf_file_path = "#{image_file_path}.pdf"
    File.binwrite(pdf_file_path, scanned_image.content)
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
      File.delete(pdf_file_path)
      File.delete(jpg_file_path)
    end
  end

  # handle updating BaptismalCertificate including
  #   attributes
  #   scanned pictures
  #   removal of scanned picture
  #
  # === Parameters:
  #
  # * <tt>:is_verify</tt> is admin verifying event
  #
  # === Returns:
  #
  # Boolean:  whether render was called
  #
  def baptismal_certificate(is_verify)
    cand_parms = params.require(:candidate).permit(
      baptismal_certificate_attributes: BaptismalCertificate.permitted_params,
      candidate_sheet_attributes: [:id,
                                   :first_name,
                                   :middle_name,
                                   :last_name]
    )

    handle_scanned_certificate(cand_parms[:baptismal_certificate_attributes])

    handle_scanned_prof(cand_parms[:baptismal_certificate_attributes])

    event_with_picture_update_private(BaptismalCertificate, admin_verified: is_verify)
  end

  def handle_scanned_prof(baptismal_certificate_params)
    baptized_at_home_parish = baptismal_certificate_params[:baptized_at_home_parish] == '1'
    baptized_catholic = baptismal_certificate_params[:baptized_catholic] == '1'
    baptismal_certificate = @candidate.baptismal_certificate
    return unless !baptized_at_home_parish && !baptized_catholic

    if baptismal_certificate_params[:remove_prof_picture] == 'Remove'
      baptismal_certificate.scanned_prof.destroy
      baptismal_certificate.scanned_certificate_id = nil
      baptismal_certificate.save!
    else
      setup_file_params(
        baptismal_certificate_params[:prof_picture],
        baptismal_certificate,
        :scanned_prof_attributes,
        params[:candidate][:baptismal_certificate_attributes]
      )
    end
  end

  def handle_scanned_certificate(baptismal_certificate_params)
    baptized_at_home_parish = baptismal_certificate_params[:baptized_at_home_parish] == '1'
    baptismal_certificate = @candidate.baptismal_certificate
    return if baptized_at_home_parish.nil?

    if baptismal_certificate_params[:remove_certificate_picture] == 'Remove'
      # tried moving this into BaptismalCertificate but the id did not get set
      baptismal_certificate.scanned_certificate.destroy
      # destroy does not set scanned_certificate_id to nil
      baptismal_certificate.scanned_certificate_id = nil
      baptismal_certificate.save!
    else
      setup_file_params(
        baptismal_certificate_params[:certificate_picture],
        baptismal_certificate,
        :scanned_certificate_attributes,
        params[:candidate][:baptismal_certificate_attributes]
      )
    end
  end

  # handle updating SponsorCovenant including
  #   attributes
  #   scanned pictures
  #   removal of scanned picture
  #
  # === Parameters:
  #
  # * <tt>:is_verify</tt> is admin verifying event
  #
  # === Returns:
  #
  # Boolean:  whether render was called
  #
  def sponsor_covenant(is_verify)
    sponsor_covenant = @candidate.sponsor_covenant
    sponsor_covenant_params = params[:candidate][:sponsor_covenant_attributes]
    if sponsor_covenant_params[:remove_sponsor_covenant_picture] == 'Remove'
      sponsor_covenant.scanned_image.destroy
      # destroy does not set scanned_covenant_id to nil
      sponsor_covenant.scanned_covenant_id = nil
      sponsor_covenant.save!
    else
      setup_file_params(sponsor_covenant_params[:sponsor_covenant_picture],
                        sponsor_covenant,
                        :scanned_covenant_attributes, sponsor_covenant_params)
    end

    event_with_picture_update_private(SponsorCovenant, admin_verified: is_verify)
  end

  # handle updating SponsorEligibility including
  #   attributes
  #   scanned pictures
  #   removal of scanned picture
  #
  # === Parameters:
  #
  # * <tt>:is_verify</tt> is admin verifying event
  #
  # === Returns:
  #
  # Boolean:  whether render was called
  #
  def sponsor_eligibility(is_verify)
    sponsor_eligibility = @candidate.sponsor_eligibility
    sponsor_eligibility_params = params[:candidate][:sponsor_eligibility_attributes]
    if sponsor_eligibility_params[:remove_sponsor_eligibility_picture] == 'Remove'
      sponsor_eligibility.scanned_image.destroy
      # destroy does not set scanned_eligibility_id to nil
      sponsor_eligibility.scanned_eligibility_id = nil
      sponsor_eligibility.save!
    else
      setup_file_params(sponsor_eligibility_params[:sponsor_eligibility_picture],
                        sponsor_eligibility,
                        :scanned_eligibility_attributes, sponsor_eligibility_params)
    end

    event_with_picture_update_private(SponsorEligibility, admin_verified: is_verify)
  end

  # handle updating RetreatVerification including
  #   attributes
  #   scanned pictures
  #   removal of scanned picture
  #
  # === Parameters:
  #
  # * <tt>:is_verify</tt> is admin verifying event
  #
  # === Returns:
  #
  # Boolean:  whether render was called
  #
  def retreat_verification(is_verify)
    retreat_verification = @candidate.retreat_verification
    retreat_verification_params = params[:candidate][:retreat_verification_attributes]

    if retreat_verification_params[:remove_retreat_verification_picture] == 'Remove'
      retreat_verification.scanned_image.destroy
      # destroy does not set scanned_retreat_id to nil
      retreat_verification.scanned_retreat_id = nil
      retreat_verification.save!
    else
      setup_file_params(
        retreat_verification_params[:retreat_verification_picture],
        retreat_verification,
        :scanned_retreat_attributes, retreat_verification_params
      )
    end
    event_with_picture_update_private(RetreatVerification, admin_verified: is_verify)
  end

  def event_with_picture_update_private(clazz, admin_verified: false)
    render_called = false
    event_key = clazz.event_key

    @candidate = Candidate.find_by(id: @candidate.id)
    if @candidate.update(candidate_params)
      adjust_for_attributes(clazz)
      candidate_event = @candidate.get_candidate_event(event_key)
      candidate_event.mark_completed(@candidate.validate_event_complete(clazz), clazz)
      if candidate_event.save
        if admin_verified
          render_called = admin_verified_private(candidate_event, event_key)
        else
          flash['notice'] =
            I18n.t('messages.updated',
                   cand_name: "#{@candidate.candidate_sheet.first_name} #{@candidate.candidate_sheet.last_name}")
        end
      else
        flash['alert'] = "Save of #{event_key} failed"
      end
    else
      flash['alert'] = I18n.t('messages.alert.common.update')
    end
    render_called
  end

  # handle the case of attributes of one event are edited
  # in another event.
  # ex: BaptismalCertificate edits the candidates' name from CandidateSheet
  #
  # A change needs to happen in
  #   admin/event_with_picture.html.erb
  #   admin/event_with_picture_verify.html.erb
  #   candidate/event_with_picture.html.erb
  #
  # === Parameters:
  #
  # * <tt>:clazz</tt> class of event being edited
  #
  def adjust_for_attributes(clazz)
    # BaptismalCertificate includes updating includes 3 attributes from CandidateSheet
    # this handles those attributes.
    if clazz == BaptismalCertificate
      bc = @candidate.baptismal_certificate
      if (bc.show_empty_radio == 1 || bc.show_empty_radio == 2) && !bc.baptized_at_home_parish?
        candidate_info_sheet_event = @candidate.get_candidate_event(CandidateSheet.event_key)
        candidate_info_sheet_event.mark_completed(@candidate.validate_event_complete(CandidateSheet),
                                                  CandidateSheet)
        @candidate.keep_bc_errors
        candidate_info_sheet_event.save
        # TODO: what happens here of if save fails
      end
    end
    # SponsorEligibility includes updating includes 1 attributes from SponsorCovenant
    # this handles that attribute.
    return unless clazz == SponsorEligibility

    candidate_info_covenant_event = @candidate.get_candidate_event(SponsorCovenant.event_key)
    candidate_info_covenant_event.mark_completed(@candidate.validate_event_complete(SponsorCovenant),
                                                 clazz)
    @candidate.keep_sponsor_name_error
    candidate_info_covenant_event.save
    # TODO: what happens here of if save fails
  end

  def setup_file_params(file, association, scanned_image_attributes, association_params)
    scanned_filename = nil
    scanned_content_type = nil
    scanned_content = nil
    scanned_image_id = nil
    if !file.nil? && association.scanned_image.nil?
      scanned_image_id = association.scanned_image_id
      scanned_filename = file ? File.basename(file.original_filename) : association.scanned_image.filename
      scanned_content_type = file ? file.content_type : association.scanned_image.content_type
      scanned_content = file ? file.read : association.scanned_image.content
    end
    return if scanned_filename.nil?

    picture_params = ActionController::Parameters.new
    picture_params[:filename] = scanned_filename
    picture_params[:content_type] = scanned_content_type
    picture_params[:content] = scanned_content
    picture_params[:id] = scanned_image_id
    association_params[scanned_image_attributes] = picture_params.permit(:filename, :content_type, :content, :id)
  end
end
