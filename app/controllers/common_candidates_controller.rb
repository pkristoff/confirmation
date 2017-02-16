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
          setup_file_params(sponsor_covenant_params[:sponsor_covenant_picture], sponsor_covenant, 'sponsor_covenant', sponsor_covenant_params)
          setup_file_params(sponsor_covenant_params[:sponsor_elegibility_picture], sponsor_covenant, 'sponsor_elegibility', sponsor_covenant_params)

          render_called = event_with_picture_update_private(SponsorCovenant)

        when Event::Route::CONFIRMATION_NAME
          pick_confirmation_name = @candidate.pick_confirmation_name
          pick_confirmation_name_params = params[:candidate][:pick_confirmation_name_attributes]
          setup_file_params(pick_confirmation_name_params[:pick_confirmation_name_picture], pick_confirmation_name, 'pick_confirmation_name', pick_confirmation_name_params)

          render_called = event_with_picture_update_private(PickConfirmationName)

        when Event::Route::BAPTISMAL_CERTIFICATE
          baptized_at_stmm = params[:candidate]['baptized_at_stmm'] == '1'
          baptismal_certificate = @candidate.baptismal_certificate
          unless baptized_at_stmm
            baptismal_certificate_params = params[:candidate][:baptismal_certificate_attributes]
            setup_file_params(baptismal_certificate_params[:certificate_picture], baptismal_certificate, 'certificate', baptismal_certificate_params)
          end

          render_called = event_with_picture_update_private(BaptismalCertificate)

        when Event::Route::RETREAT_VERIFICATION
          retreat_verification = @candidate.retreat_verification
          retreat_verification_params = params[:candidate][:retreat_verification_attributes]
          setup_file_params(retreat_verification_params[:retreat_verification_picture], retreat_verification, 'retreat_verification', retreat_verification_params)

          render_called = event_with_picture_update_private(RetreatVerification)
        else
          flash[:alert] = "Unknown event_name: #{event_name}"
      end
    else
      flash[:alert] = I18n.t('messages.unknown_parameter', name: 'candidate')
    end
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
    association = nil
    case params[:event_name].to_sym
      when Event::Route::CONFIRMATION_NAME
        association = @candidate.pick_confirmation_name
      when Event::Route::BAPTISMAL_CERTIFICATE
        association = @candidate.baptismal_certificate
      when Event::Route::SPONSOR_COVENANT
        association = @candidate.sponsor_covenant
      when Event::Route::RETREAT_VERIFICATION
        association = @candidate.retreat_verification
      else
        flash['alert'] = "Unknown event_name #{params[:event_name]}"
    end
    send_image(association) unless association.nil?
  end

  def sign_agreement
    @candidate = Candidate.find(params[:id])
    @resource = @candidate
  end

  def sign_agreement_update
    return aggreement_update_private(I18n.t('events.candidate_covenant_agreement'), 'signed_agreement')
  end

  def aggreement_update_private(event_name, signed_param_name)
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
          return redirect_to :back, alert: I18n.t('messages.unknown_parameter', name: "['candidate'][signed_param_name]: %{params['candidate'][signed_param_name]")
        end
      end
    else
      return redirect_to :back, alert: I18n.t('messages.unknown_parameter', name: 'candidate')
    end

    if candidate.update_attributes(candidate_params)
      if is_admin?
        redirect_to candidates_path, notice: I18n.t('messages.updated')
      else
        redirect_to event_candidate_registration_path(params[:id]), notice: I18n.t('messages.updated')
      end
    else
      redirect_to :back, alert: I18n.t('messages.save_failed')
    end
  end

  def sponsor_agreement
    @candidate = Candidate.find(params[:id])
    @resource = @candidate
  end

  def sponsor_agreement_update
    return aggreement_update_private(I18n.t('events.sponsor_agreement'), 'sponsor_agreement')
  end

  def event_with_picture
    @candidate = Candidate.find(params[:id])
    @resource = @candidate
    event_name = params[:event_name]
    render_event_with_picture(false, event_name)
  end

  def upload_sponsor_elegibility_image
    @candidate = Candidate.find(params[:id])
    sponsor_covenant = @candidate.sponsor_covenant
    send_data sponsor_covenant.sponsor_elegibility_file_contents,
              type: sponsor_covenant.sponsor_elegibility_content_type,
              disposition: 'inline'
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
          candidate_event.verified = [CandidateSheet, ChristianMinistry, PickConfirmationName, ].include?(clazz)
          if candidate_event.save
            render_called = true
            if is_admin?
              redirect_to candidates_path, notice: I18n.t('messages.updated')
            else
              redirect_to event_candidate_registration_path(params[:id]), notice: I18n.t('messages.updated')
            end
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

  def send_image(association)
    send_data association.file_contents,
              type: association.content_type,
              disposition: 'inline'
  end

  def setup_file_params(file, association, prefix, association_params)
    is_sponsor_elegibillity = prefix === 'sponsor_elegibility'
    filename_param = is_sponsor_elegibillity ? "#{prefix}_filename".to_sym : association.filename_param
    content_type_param = is_sponsor_elegibillity ? "#{prefix}_content_type".to_sym : association.content_type_param
    file_contents_param = is_sponsor_elegibillity ? "#{prefix}_file_contents".to_sym : association.file_contents_param
    if is_sponsor_elegibillity
      filename = association.sponsor_elegibility_filename
      content_type = association.sponsor_elegibility_content_type
      file_contents = association.sponsor_elegibility_file_contents
    else
      filename = association.filename
      content_type = association.content_type
      file_contents = association.file_contents
    end
    if file
      if File.basename(file.original_filename) === filename
        association_params[filename_param] = filename
        association_params[content_type_param] = content_type
        association_params[file_contents_param] = file_contents
      else
        association_params[filename_param] = File.basename(file.original_filename)
        association_params[content_type_param] = file.content_type
        # the encode here is to fix error with this message: ArgumentError: string contains null byte
        # i know i fixed this before but cannot not figure out how.
        association_params[file_contents_param] = Base64.encode64(file.read)
      end
    else
      association_params[filename_param] = filename
      association_params[content_type_param] = content_type
      association_params[file_contents_param] = file_contents
    end
  end


end