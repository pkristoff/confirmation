class UsersController < ApplicationController

  attr_accessor :users # for testing
  attr_accessor :user # for testing

  before_action :check_user_or_admin_logged_in!

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
    unless admin_signed_in? or @user == current_user
      redirect_to :back, :alert => "Access denied."
    end
  end

  private
  def check_user_or_admin_logged_in!
    authenticate_user! unless admin_signed_in?
  end

end
