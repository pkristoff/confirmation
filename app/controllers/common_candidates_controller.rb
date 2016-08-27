class CommonCandidatesController < ApplicationController

  DOCUMENT_KEY_TO_NAME = {
      covenant: '4. Candidate Covenant Form.pdf', # complete
      baptismal_certificate: '6. Baptismal Certificate.pdf', # complete
      sponsor_covenant: '7. Sponsor Covenant & Eligibility.pdf', # complete
      conversation_sponsor_candidate: '8. Conversation between Sponsor & Candidate.pdf',
      ministry_awareness: '9. Christian Ministry Awareness.pdf',
      confirmation_name: '10. Choosing a Confirmation Name.pdf' # complete
  }

  def baptismal_certificate_update
    @candidate = Candidate.find(params[:id])
    if params['candidate']
      baptized_at_stmm = params[:candidate]['baptized_at_stmm'] == '1'
      baptismal_certificate = @candidate.baptismal_certificate
      unless baptized_at_stmm
        baptismal_certificate_params = params[:candidate][:baptismal_certificate_attributes]
        setup_file_params(baptismal_certificate_params[:certificate_picture], baptismal_certificate, 'certificate', baptismal_certificate_params)
      end

      association_update(BaptismalCertificate,)

    else
      flash[:alert] = I18n.t('messages.unknown_parameter')
    end
  end

  def pick_confirmation_name_update
    @candidate = Candidate.find(params[:id])
    if params['candidate']
      pick_confirmation_name = @candidate.pick_confirmation_name
      pick_confirmation_name_params = params[:candidate][:pick_confirmation_name_attributes]
      setup_file_params(pick_confirmation_name_params[:pick_confirmation_name_picture], pick_confirmation_name, 'pick_confirmation_name', pick_confirmation_name_params)

      association_update(PickConfirmationName)
    else
      flash[:alert] = I18n.t('messages.unknown_parameter')
    end
  end

  def sponsor_covenant_update
    @candidate = Candidate.find(params[:id])
    if params['candidate']
      sponsor_covenant = @candidate.sponsor_covenant
      sponsor_covenant_params = params[:candidate][:sponsor_covenant_attributes]
      setup_file_params(sponsor_covenant_params[:sponsor_covenant_picture], sponsor_covenant, 'sponsor_covenant', sponsor_covenant_params)
      setup_file_params(sponsor_covenant_params[:sponsor_elegibility_picture], sponsor_covenant, 'sponsor_elegibility', sponsor_covenant_params)

      association_update(SponsorCovenant)
    else
      flash[:alert] = I18n.t('messages.unknown_parameter')
    end
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
    doc_name = DOCUMENT_KEY_TO_NAME[params[:name].to_sym]
    pdf = File.new("public/documents/#{doc_name}")
    pdf_data = File.read(pdf.path)
    begin
      send_data(pdf_data, type: 'application/pdf', filename: doc_name)
    ensure
      pdf.close
    end

  end

  def show_baptism_certificate
    @candidate = Candidate.find(params[:id])
    send_image(@candidate.baptismal_certificate)
  end

  def show_sponsor_elegibility
    @candidate = Candidate.find(params[:id])
    sponsor_covenant = @candidate.sponsor_covenant
    send_data sponsor_covenant.sponsor_elegibility_file_contents,
              type: sponsor_covenant.sponsor_elegibility_content_type,
              disposition: 'inline'
  end

  def show_sponsor_covenant
    @candidate = Candidate.find(params[:id])
    send_image(@candidate.sponsor_covenant)
  end

  def show_pick_confirmation_name
    @candidate = Candidate.find(params[:id])
    send_image(@candidate.pick_confirmation_name)
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

  def upload_baptismal_certificate
    @candidate = Candidate.find(params[:id])
    @resource = @candidate
  end

  def upload_sponsor_covenant
    @candidate = Candidate.find(params[:id])
    @resource = @candidate
  end

  def pick_confirmation_name
    @candidate = Candidate.find(params[:id])
    @resource = @candidate
  end

  def upload_baptismal_certificate_image
    @candidate = Candidate.find(params[:id])
    send_image(@candidate.baptismal_certificate)
  end

  def upload_sponsor_elegibility_image
    @candidate = Candidate.find(params[:id])
    sponsor_covenant = @candidate.sponsor_covenant
    send_data sponsor_covenant.sponsor_elegibility_file_contents,
              type: sponsor_covenant.sponsor_elegibility_content_type,
              disposition: 'inline'
  end

  def upload_sponsor_covenant_image
    @candidate = Candidate.find(params[:id])
    send_image(@candidate.sponsor_covenant)
  end

  def pick_confirmation_name_image
    @candidate = Candidate.find(params[:id])
    send_image(@candidate.pick_confirmation_name)
  end

  private

  def association_update(clazz)
    event_name = clazz.event_name
    if @candidate.update_attributes(candidate_params)
      if @candidate.validate_event_complete(clazz)
        unless @candidate.errors.any?
          candidate_event = @candidate.candidate_events.find { |ce| ce.name == event_name }
          candidate_event.completed_date = Date.today
          if @candidate.save
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