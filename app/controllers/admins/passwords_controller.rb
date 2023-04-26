# frozen_string_literal: true

# rubocop:disable Style/ClassAndModuleChildren

#
# Custom Devise Mailer tasks
#
class Admins::PasswordsController < Devise::PasswordsController
  # creates an email to send to admin's email on how reset password
  #
  # === Attributes:
  #
  # * <tt>:email</tt>
  #
  def create
    admin_params = params[:admin]
    email = admin_params[:email]
    found_admin = Admin.find_by(email: email)
    if found_admin
      admin_params[:account_name] = found_admin.account_name
    else
      admin_params[:account_name] = 'made up account name'
      flash.now[:alert] = I18n.t('messages.flash.alert.admin.reset_password_failed', email: email)
    end
    super
  end
end
# rubocop:enable Style/ClassAndModuleChildren
