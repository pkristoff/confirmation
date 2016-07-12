module ControllerMacros
  def login_admin
    @request.env['devise.mapping'] = Devise.mappings[:admin]
    xxxadmin = FactoryGirl.create(:admin)
    sign_in xxxadmin
    xxxadmin
  end

  def login_candidate
    @request.env['devise.mapping'] = Devise.mappings[:candidate]
    xxxcandidate = FactoryGirl.create(:candidate)
    sign_in xxxcandidate
    xxxcandidate
  end
end