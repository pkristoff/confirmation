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
    xxxcandidate = FactoryBot.create(:candidate)
    sign_in xxxcandidate
    xxxcandidate
  end
end
