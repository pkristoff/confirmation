class AdminsController < ApplicationController

  attr_accessor :admins # for testing

  before_action :authenticate_admin!
  before_action :puts_controller

  def index
    @admins = Admin.all
  end

  def show
    @admin = Admin.find(params[:id])
    unless @admin == current_admin
      redirect_to :back, :alert => "Access denied."
    end
  end

end
