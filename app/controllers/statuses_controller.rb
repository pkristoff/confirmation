# frozen_string_literal: true

# StatusesController
#
class StatusesController < ApplicationController
  before_action :set_status, only: %i[show edit update destroy]

  # GET /statuses or /statuses.json
  #
  def index
    @statuses = Status.all
  end

  # GET /statuses/1 or /statuses/1.json
  #
  def show; end

  # GET /statuses/new
  #
  def new
    @status = Status.new
  end

  # GET /statuses/1/edit
  #
  def edit; end

  # POST /statuses or /statuses.json
  #
  def create
    @status = Status.new(status_params)

    respond_to do |format|
      if @status.save
        format.html { redirect_to status_url(@status), notice: I18n.t('messages.status_successfully_created') }
        # format.json { render :show, status: :created, location: @status }
      else
        format.html { render :new, status: :unprocessable_entity }
        # format.json { render json: @status.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /statuses/1 or /statuses/1.json
  #
  def update
    respond_to do |format|
      if @status.update(status_params)
        flash[:notice] = I18n.t('messages.flash.alert.status.updated')
        format.html { redirect_to status_url(@status) }
        format.json { render :show, status: :ok, location: @status }
      else
        flash[:alert] = I18n.t('messages.flash.alert.status.not_updated')
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @status.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /statuses/1 or /statuses/1.json
  #
  def destroy
    if @status.used_by_candidate?
      respond_to do |format|
        format.html do
          redirect_to statuses_url,
                      alert: I18n.t('messages.status_not_destroyed')
        end
      end
    else
      @status.destroy
      respond_to do |format|
        format.html do
          redirect_to statuses_url,
                      notice: I18n.t('messages.status_successfully_destroyed')
        end
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_status
    @status = Status.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def status_params
    params.require(:status).permit(:name, :description)
  end
end
