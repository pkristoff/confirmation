class CommonCandidatesController < ApplicationController

  def baptismal_certificate_update
    @candidate = Candidate.find(params[:id])
    if params['candidate']
      baptized_at_stmm = params[:candidate]['baptized_at_stmm'] == '1'
      if baptized_at_stmm
        @candidate.baptismal_certificate = nil
        params[:candidate].delete(:baptismal_certificate_attributes)
        # Update candidate_event
        candidate_event = @candidate.candidate_events.find { |ce| ce.name == I18n.t('events.upload_baptismal_certificate') }
        candidate_event.completed_date = Date.today

        if @candidate.update_attributes(candidate_params)
          if is_admin?
            redirect_to event_candidate_registration_path(params[:id]), notice: I18n.t('messages.updated')
          else
            redirect_to event_candidate_path(params[:id]), notice: I18n.t('messages.updated')
          end
        else
          # let it fall through
        end
      else
        # this is tricky here.  trying to allow the user to see the scanned picture
        # and not have to re-upload it, if they get a validation error
        baptismal_cert_params = params[:candidate][:baptismal_certificate_attributes]
        if baptismal_cert_params
          file_error = false
          @candidate.baptismal_certificate = create_baptismal_certificate if @candidate.baptismal_certificate.nil?
          baptismal_certificate = @candidate.baptismal_certificate
          # update file params for the save
          file = baptismal_cert_params[:certificate_picture]
          if file.nil?
            if baptismal_certificate && baptismal_certificate.certificate_filename
              # already saved the BC picture
              baptismal_cert_params[:certificate_filename] = baptismal_certificate.certificate_filename
              baptismal_cert_params[:certificate_content_type] = baptismal_certificate.certificate_content_type
              baptismal_cert_params[:certificate_file_contents] = baptismal_certificate.certificate_file_contents
            else
              # scanned BC required
              file_error = true
              flash['alert'] = I18n.t('messages.certificate_not_blank')
            end
          else
            # setup scanned BC for saving
            baptismal_cert_params[:certificate_filename] = File.basename(file.original_filename)
            baptismal_cert_params[:certificate_content_type] = file.content_type
            baptismal_cert_params[:certificate_file_contents] = file.read
            # save BC picture.
            if @candidate.update_attributes(certificate_file_params)
              # redirect_to event_candidate_registration_path(params[:id]), notice: I18n.t('messages.updated')
            else
              # let it fall through
            end
          end

          if @candidate.update_attributes(candidate_params)
            unless file_error
              # Update candidate_event
              candidate_event = @candidate.candidate_events.find { |ce| ce.name == I18n.t('events.upload_baptismal_certificate') }
              candidate_event.completed_date = Date.today
              candidate_event.save
              if is_admin?
                redirect_to event_candidate_registration_path(params[:id]), notice: I18n.t('messages.updated')
              else
                redirect_to event_candidate_path(params[:id]), notice: I18n.t('messages.updated')
              end
            end

          else
            'remove me'

          end
        else
          flash['alert'] = I18n.t('messages.missing_baptismal_certificate_attributes')
          return
        end
      end
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
    pdf = File.new("public/documents/4. Candidate Covenant Form.pdf")
    pdf_data = File.read(pdf.path)
    begin
      send_data(pdf_data, type: 'application/pdf', filename: 'Candidate Covenant Form.pdf')
    ensure
      pdf.close
    end

  end

  def show_baptism_certificate
    @candidate = Candidate.find(params[:id])
    send_image(@candidate)
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
    if @candidate.baptismal_certificate.nil?
      @candidate.baptismal_certificate = create_baptismal_certificate
    end
  end

  def upload_baptismal_certificate_image
    @candidate = Candidate.find(params[:id])
    send_image(@candidate)
  end

  private

  def send_image(candidate)
    baptismal_certificate = candidate.baptismal_certificate
    send_data baptismal_certificate.certificate_file_contents,
              type: baptismal_certificate.certificate_content_type,
              disposition: 'inline'
  end

  def create_baptismal_certificate
    baptismal_certificate = BaptismalCertificate.new
    baptismal_certificate.church_address = Address.new
    baptismal_certificate
  end
end