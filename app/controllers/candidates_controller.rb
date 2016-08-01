class CandidatesController < ApplicationController

  # ADMIN ONLY

  helper DeviseHelper

  helpers = %w(resource scope_name resource_name signed_in_resource
               resource_class resource_params devise_mapping)
  helper_method(*helpers)

  attr_accessor :candidates # for testing
  attr_accessor :candidate # for testing

  before_action :authenticate_admin!

  def destroy
    @candidate = Candidate.find(params[:id])
    @candidate.destroy
    flash[:notice] = I18n.t('messages.candidate_removed', name: candidate.account_name)
    @candidates = Candidate.all
    render :index
  end

  def edit
    @candidate = Candidate.find(params[:id])
    @resource = @candidate
  end

  def event
    @resource = Candidate.find(params[:id])
  end

  def index
    @candidates = Candidate.all
  end

  def new
    @resource = AppFactory.create_candidate
  end

  def show
    @candidate = Candidate.find(params[:id])
  end

  def update
    if params[:candidate][:password].blank?
      params[:candidate].delete(:password)
      params[:candidate].delete(:password_confirmation)
    end
    @resource = Candidate.find(params[:id])
    # puts candidate_params
    if @resource.update_attributes(candidate_params)
      flash[:notice] = I18n.t('messages.candidate_updated', name: @resource.account_name)
      render :event, id: @resource.id
    else
      render edit
    end
  end



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
          redirect_to event_candidate_path(params[:id]), notice: I18n.t('messages.updated')
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
              redirect_to event_candidate_path(params[:id]), notice: I18n.t('messages.updated')
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

  def show_baptism_certificate
    @candidate = Candidate.find(params[:id])
    send_image(@candidate)
    # baptismal_certificate = @candidate.baptismal_certificate
    # send_data baptismal_certificate.certificate_file_contents,
    #           type: baptismal_certificate.certificate_content_type,
    #           disposition: 'inline'
  end

  def upload_baptismal_certificate
    @candidate = Candidate.find(params[:id])
    if @candidate.baptismal_certificate.nil?
      @candidate.baptismal_certificate = create_baptismal_certificate
    end
  end

  def upload_baptismal_certificate_image
    @candidate = Candidate.find(params[:id])
    send_image(@candidate)
    # send_data(@candidate.baptismal_certificate.certificate_file_contents,
    #           :filename => @candidate.baptismal_certificate.certificate_filename,
    #           :type => @candidate.baptismal_certificate.certificate_content_type,
    #           :disposition => 'inline')
  end

  private

  def create_baptismal_certificate
    baptismal_certificate = BaptismalCertificate.new
    baptismal_certificate.church_address = Address.new
    baptismal_certificate
  end

  def send_image(candidate)
    baptismal_certificate = candidate.baptismal_certificate
    send_data baptismal_certificate.certificate_file_contents,
              type: baptismal_certificate.certificate_content_type,
              disposition: 'inline'
  end



  protected
  def resource_class
    devise_mapping.to
  end

  # Since going around devise mechanisms - add some helpers back in.
  def resource
    @resource
  end

  # Since going around devise mechanisms - add some helpers back in.
  def resource_name
    devise_mapping.name
  end

  # Since going around devise mechanisms - add some helpers back in.
  def devise_mapping
    Devise.mappings[:candidate]
  end

end
