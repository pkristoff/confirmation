module ControllerMacros
  def login_admin
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:admin]
      sign_in FactoryGirl.create(:admin) # Using factory girl as an example
    end
  end

  def login_candidate
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:candidate]
      candidate = FactoryGirl.create(:candidate)
      sign_in candidate
    end
  end
end