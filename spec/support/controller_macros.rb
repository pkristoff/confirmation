# frozen_string_literal: true

# ControllerMacros
#
module ControllerMacros
  # login as Admin
  #
  # === Parameters:
  #
  # * <tt>:admin_to_use</tt>
  #
  def login_admin(**admin_to_use)
    @request.env['devise.mapping'] = Devise.mappings[:admin]
    admin = admin_to_use[:admin] || FactoryBot.create(:admin)
    sign_in admin
    admin
  end

  # login as Candidate
  #
  def login_candidate
    @request.env['devise.mapping'] = Devise.mappings[:candidate]
    AppFactory.generate_default_status if Status.count == 0
    candidate = FactoryBot.create(:candidate)
    sign_in candidate
    candidate
  end
end
