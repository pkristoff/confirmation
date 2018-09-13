# frozen_string_literal: true

#
# Handles Admin tasks
#
class VisitorsController < ApplicationController
  # setup for about page on the top menu bar.
  #
  def about
    @visitor = Visitor.first
  end

  # setup for about app page in help menu
  #
  def about_app
    @visitor = Visitor.first
  end

  # redirect to appropriate routing depending who is logged in.
  #
  def index
    if candidate_signed_in?
      redirect_to dev_candidate_path(current_candidate.id)
    elsif admin_signed_in?
      redirect_to admin_path(current_admin.id)
    end
    @candidate = nil
    @visitor = Visitor.first
  end

  # If id == -1 then create a new candidate otherwise find one.
  #
  # === Attributes
  #
  # * <tt>:id</tt> Candidate id
  # * <tt>:erros</tt>
  #
  def cand_account_confirmation
    @candidate = params[:id].to_i.equal?('-1'.to_i) ? Candidate.create : Candidate.find(params[:id])
    @errors = params[:errors]

    send_grid_mail = SendGridMail.new(current_admin, [@candidate])
    response, _token = send_grid_mail.reset_password
    if response.nil? && Rails.env.test?
      # not connected to the internet while testing
      flash[:notice] = I18n.t('messages.reset_password_message_sent')
    elsif response.status_code[0] == '2'
      flash[:notice] = I18n.t('messages.reset_password_message_sent')
    else
      flash[:alert] = "Status=#{response.status_code} body=#{response.body}"
    end

    sign_out current_admin if admin_signed_in?
  end

  # Devise method
  #
  # === Returns:
  #
  # * <tt>Candidate</tt>
  #
  def resource
    @candidate
  end
end
