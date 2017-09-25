require 'constants'

class CommonCandidatesController < ApplicationController

  def event_with_picture_update
    render_called = false
    candidate_id = params[:id]
    event_name = params[:event_name]
    @candidate = Candidate.find(candidate_id)
    @candidate_event = @candidate.get_candidate_event(I18n.t("events.#{event_name}"))
    if params['candidate']
      case event_name.to_sym
        when Event::Route::SPONSOR_COVENANT
          sponsor_covenant = @candidate.sponsor_covenant
          sponsor_covenant_params = params[:candidate][:sponsor_covenant_attributes]
          setup_file_params(sponsor_covenant_params[:sponsor_covenant_picture], sponsor_covenant, :scanned_covenant_attributes, sponsor_covenant_params)
          setup_file_params(sponsor_covenant_params[:sponsor_eligibility_picture], sponsor_covenant, :scanned_eligibility_attributes, sponsor_covenant_params)

          render_called = event_with_picture_update_private(SponsorCovenant)

        when Event::Route::BAPTISMAL_CERTIFICATE
          baptized_at_stmm = params[:candidate]['baptized_at_stmm'] == '1'
          baptismal_certificate = @candidate.baptismal_certificate
          unless baptized_at_stmm
            baptismal_certificate_params = params[:candidate][:baptismal_certificate_attributes]
            setup_file_params(baptismal_certificate_params[:certificate_picture], baptismal_certificate, :scanned_certificate_attributes, baptismal_certificate_params)
          end

          render_called = event_with_picture_update_private(BaptismalCertificate)

        when Event::Route::RETREAT_VERIFICATION
          retreat_verification = @candidate.retreat_verification
          retreat_verification_params = params[:candidate][:retreat_verification_attributes]
          setup_file_params(retreat_verification_params[:retreat_verification_picture], retreat_verification, :scanned_retreat_attributes, retreat_verification_params)

          render_called = event_with_picture_update_private(RetreatVerification)
        else
          flash[:alert] = "Unknown event_name: #{event_name}"
      end
    else
      flash[:alert] = I18n.t('messages.unknown_parameter', name: 'candidate')
    end
    @resource = @candidate
    render_event_with_picture(render_called, event_name)

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
    @candidate = Candidate.find(params[:id])
    @resource = @candidate
  end

  def sign_agreement_update
    rendered_called = agreement_update_private(I18n.t('events.candidate_covenant_agreement'), 'signed_agreement')
    unless rendered_called
      @candidate = Candidate.find(params[:id])
      @resource = @candidate
      render :sign_agreement
    end
  end

  def agreement_update_private(event_name, signed_param_name)
    candidate = Candidate.find(params[:id])
    candidate_event = candidate.get_candidate_event(event_name)
    if params['candidate']
      # TODO move logic to association instance.
      if params['candidate'][signed_param_name] === '1'
        candidate_event.completed_date = Date.today
        candidate_event.verified = true
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

    if candidate.update_attributes(candidate_params)
      @candidate = Candidate.find(params[:id])
      @resource = @candidate
      flash['notice'] = I18n.t('messages.updated')
      false
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
    agreement_update_private(I18n.t('events.sponsor_agreement'), 'sponsor_agreement')
    @candidate = Candidate.find(params[:id])
    @resource = @candidate
    render :sponsor_agreement
  end

  def event_with_picture
    @candidate = Candidate.find(params[:id])
    @resource = @candidate
    event_name = params[:event_name]
    render_event_with_picture(false, event_name)
  end

  def upload_sponsor_eligibility_image
    @candidate = Candidate.find(params[:id])
    scanned_image = @candidate.sponsor_covenant.scanned_eligibility
    send_image(scanned_image) unless scanned_image.nil?
  end

  private

  def event_with_picture_update_private(clazz)
    render_called = false
    event_name = clazz.event_name
    if @candidate.update_attributes(candidate_params)
      if @candidate.validate_event_complete(clazz)
        unless @candidate.errors.any?
          candidate_event = @candidate.get_candidate_event(event_name)
          candidate_event.completed_date = Date.today
          # TODO move logic to association instance.
          candidate_event.verified = [CandidateSheet, ChristianMinistry].include?(clazz)
          if candidate_event.save
            render_called = false
            # @resource = @candidate
            flash['notice'] = I18n.t('messages.updated')
          else
            flash['alert'] = "Save of #{event_name} failed"
          end
        end
      end
    else
      flash['alert'] = 'Update_attributes fails'
    end
    render_called
  end

  def render_event_with_picture(render_called, event_name)
    unless render_called
      @event_with_picture_name = event_name
      @is_dev = !is_admin?

      @candidate_event = @candidate.get_candidate_event(I18n.t("events.#{event_name}"))
      flash[:alert] = "Internal Error: unknown event: #{event_name}: #{I18n.t("events.#{event_name}")}" if @candidate_event.nil?
      render :event_with_picture
    end
  end

  def send_image(scanned_image)
    conts = scanned_image.content
    send_data conts,
              type: scanned_image.content_type,
              disposition: 'inline'
  end

  def setup_file_params(file, association, scanned_image_attributes, association_params)

    scanned_filename = nil
    scanned_content_type = nil
    scanned_content = nil
    case scanned_image_attributes
      when :scanned_certificate_attributes
        unless file.nil? && association.scanned_certificate.nil?
          scanned_filename = file ? File.basename(file.original_filename) : association.scanned_certificate.filename
          scanned_content_type = file ? file.content_type : association.scanned_certificate.content_type
          scanned_content = file ? file.read : association.scanned_certificate.content
        end
      when :scanned_retreat_attributes
        unless file.nil? && association.scanned_retreat.nil?
          scanned_filename = file ? File.basename(file.original_filename) : association.scanned_retreat.filename
          scanned_content_type = file ? file.content_type : association.scanned_retreat.content_type
          scanned_content = file ? file.read : association.scanned_retreat.content
        end
      when :scanned_eligibility_attributes
        unless file.nil? && association.scanned_eligibility.nil?
          scanned_filename = file ? File.basename(file.original_filename) : association.scanned_eligibility.filename
          scanned_content_type = file ? file.content_type : association.scanned_eligibility.content_type
          scanned_content = file ? file.read : association.scanned_eligibility.content
        end
      when :scanned_covenant_attributes
        unless file.nil? && association.scanned_covenant.nil?
          scanned_filename = file ? File.basename(file.original_filename) : association.scanned_covenant.filename
          scanned_content_type = file ? file.content_type : association.scanned_covenant.content_type
          scanned_content = file ? file.read : association.scanned_covenant.content
        end
      else
        raise "Unknown scanned_image_attributes #{scanned_image_attributes}"
    end
    unless scanned_filename.nil?
      # The problem is that while running tests if I do NOT do encode64 the tests
      # break with this message: ArgumentError: string contains null byte
      #  if it is left in all the time then the png does not show up in the browser.
      # scanned_content = Base64.encode64(scanned_content) if file && (File.basename(file.original_filename) === 'actions for spec testing.png')

      picture_params = ActionController::Parameters.new
      association_params[scanned_image_attributes] = picture_params
      picture_params[:filename] = scanned_filename
      picture_params[:content_type] = scanned_content_type
      picture_params[:content] = scanned_content
    end
  end

end