# frozen_string_literal: true

# ControllerMacros
#
module ControllerMacros
  # login as Admin
  #
  def login_admin
    @request.env['devise.mapping'] = Devise.mappings[:admin]
    xxxadmin = FactoryBot.create(:admin)
    sign_in xxxadmin
    xxxadmin
  end

  # login as Candidate
  #
  def login_candidate
    @request.env['devise.mapping'] = Devise.mappings[:candidate]
    AppFactory.generate_default_status if Status.count == 0
    xxxcandidate = FactoryBot.create(:candidate)
    sign_in xxxcandidate
    xxxcandidate
  end
end
