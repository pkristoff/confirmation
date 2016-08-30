class CommonCandidatesController < ApplicationController

  def event_with_picture_update
    render_called = false
    candidate_id = params[:id]
    event_name = params[:event_name]
    @candidate = Candidate.find(candidate_id)
    if params['candidate']
      case event_name.to_sym
        when Event::Route::UPLOAD_SPONSOR_COVENANT
          sponsor_covenant = @candidate.sponsor_covenant
          sponsor_covenant_params = params[:candidate][:sponsor_covenant_attributes]
          setup_file_params(sponsor_covenant_params[:sponsor_covenant_picture], sponsor_covenant, 'sponsor_covenant', sponsor_covenant_params)
          setup_file_params(sponsor_covenant_params[:sponsor_elegibility_picture], sponsor_covenant, 'sponsor_elegibility', sponsor_covenant_params)

           render_called = event_with_picture_update_private(SponsorCovenant)

        when Event::Route::PICK_CONFIRMATION_NAME
          pick_confirmation_name = @candidate.pick_confirmation_name
          pick_confirmation_name_params = params[:candidate][:pick_confirmation_name_attributes]
          setup_file_params(pick_confirmation_name_params[:pick_confirmation_name_picture], pick_confirmation_name, 'pick_confirmation_name', pick_confirmation_name_params)

          render_called = event_with_picture_update_private(PickConfirmationName)

        when Event::Route::UPLOAD_BAPTISMAL_CERTIFICATE
          baptized_at_stmm = params[:candidate]['baptized_at_stmm'] == '1'
          baptismal_certificate = @candidate.baptismal_certificate
          unless baptized_at_stmm
            baptismal_certificate_params = params[:candidate][:baptismal_certificate_attributes]
            setup_file_params(baptismal_certificate_params[:certificate_picture], baptismal_certificate, 'certificate', baptismal_certificate_params)
          end

          render_called = event_with_picture_update_private(BaptismalCertificate,)
        else
          flash[:alert] = "Unknowwn event_name: #{event_name}"
      end
    else
      flash[:alert] = I18n.t('messages.unknown_parameter')
    end
    render_event_with_picture(render_called, event_name)

  end

  def candidate_sheet
    @candidate = Candidate.find(params[:id])
    @resource = @candidate
  end

  def candidate_sheet_update
    candidate = Candidate.find(params[:id])
    candidate_event = candidate.candidate_events.find { |ce| ce.name == I18n.t('events.fill_out_candidate_sheet') }
    candidate_event.completed_date = Date.today

    if candidate.update_attributes(candidate_params)
      if is_admin?
        redirect_to event_candidate_registration_path(params[:id]), notice: 'Updated'
      else
        redirect_to event_candidate_path(params[:id]), notice: 'Updated'
      end
    else
      redirect_to :back, alert: 'Saving failed.'
    end
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

  def show_event_with_picture
    @candidate = Candidate.find(params[:id])
    association = nil
    case params[:event_name].to_sym
      when Event::Route::PICK_CONFIRMATION_NAME
        association = @candidate.pick_confirmation_name
      when Event::Route::BAPTISMAL_CERTIFICATE_UPDATE
        association = @candidate.baptismal_certificate
      when Event::Route::SPONSOR_COVENANT_UPDATE
        association = @candidate.sponsor_covenant
      else
        flash['alert'] = "Unknown event_name #{params[:event_name]}"
    end
    send_image(association)
  end

  def event_with_picture_image
    @candidate = Candidate.find(params[:id])
    association = nil
    case params[:event_name].to_sym
      when Event::Route::PICK_CONFIRMATION_NAME
        association = @candidate.pick_confirmation_name
      when Event::Route::UPLOAD_BAPTISMAL_CERTIFICATE
        association = @candidate.baptismal_certificate
      when Event::Route::UPLOAD_SPONSOR_COVENANT
        association = @candidate.sponsor_covenant
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
    candidate = Candidate.find(params[:id])
    candidate_event = candidate.candidate_events.find { |ce| ce.name == I18n.t('events.sign_agreement') }
    if params['candidate']
      if params['candidate']['signed_agreement'] === '1'
        candidate_event.completed_date = Date.today
      else
        if params['candidate']['signed_agreement'] === '0'
          candidate_event.completed_date = nil
          candidate_event.verified = false
        else
          return redirect_to :back, alert: 'Unknown Parameter'
        end
      end
    else
      return redirect_to :back, alert: 'Unknown Parameter'
    end

    if candidate.update_attributes(candidate_params)
      if is_admin?
        redirect_to event_candidate_registration_path(params[:id]), notice: I18n.t('messages.updated')
      else
        redirect_to event_candidate_path(params[:id]), notice: I18n.t('messages.updated')
      end
    else
      redirect_to :back, alert: 'Saving failed.'
    end
  end

  # TODO: merge with sign_agreement
  def sponsor_agreement
    @candidate = Candidate.find(params[:id])
    @resource = @candidate
  end

  def sponsor_agreement_update
    candidate = Candidate.find(params[:id])
    candidate_event = candidate.candidate_events.find { |ce| ce.name == I18n.t('events.sponsor_agreement') }
    if params['candidate']
      if params['candidate']['sponsor_agreement'] === '1'
        candidate_event.completed_date = Date.today
      else
        if params['candidate']['sponsor_agreement'] === '0'
          candidate_event.completed_date = nil
          candidate_event.verified = false
        else
          return redirect_to :back, alert: 'Unknown Parameter'
        end
      end
    else
      return redirect_to :back, alert: 'Unknown Parameter'
    end

    if candidate.update_attributes(candidate_params)
      if is_admin?
        redirect_to event_candidate_registration_path(params[:id]), notice: I18n.t('messages.updated')
      else
        redirect_to event_candidate_path(params[:id]), notice: I18n.t('messages.updated')
      end
    else
      redirect_to :back, alert: 'Saving failed.'
    end
  end

  def event_with_picture
    @candidate = Candidate.find(params[:id])
    @resource = @candidate
    render_event_with_picture(false, params[:event_name])
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
          candidate_event = @candidate.candidate_events.find { |ce| ce.name == event_name }
          candidate_event.completed_date = Date.today
          if @candidate.save
            render_called = true
            if is_admin?
              redirect_to event_candidate_registration_path(params[:id]), notice: I18n.t('messages.updated')
            else
              redirect_to event_candidate_path(params[:id]), notice: I18n.t('messages.updated')
            end
          else
            flash['alert'] = "Save of #{event_name} failed"
          end
        end
      end
    end
    render_called
  end

  def render_event_with_picture(render_called, event_name)
    unless render_called
      @event_with_picture_name = event_name
      @is_dev = is_admin?
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
        association_params[file_contents_param] = file.read
      end
    else
      association_params[filename_param] = filename
      association_params[content_type_param] = content_type
      association_params[file_contents_param] = file_contents
    end
  end


end