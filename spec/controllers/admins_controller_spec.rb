
describe UsersController do

  it "should have a current_user" do
    expect(subject.current_user).to eq(nil)
  end

  it "should have a current_admin" do
    login_admin
    get :index
    expect(@users).to eq(nil)
  end

  it "should have a current_admin" do
    login_user
    get :index
    expect(subject.users.size).to eq(1)
  end

end




def login_user
  @request.env["devise.mapping"] = Devise.mappings[:user]
  @user = FactoryGirl.create(:user)
  sign_in @user
end
def login_admin
  @request.env["devise.mapping"] = Devise.mappings[:admin]
  @admin = FactoryGirl.create(:admin)
  sign_in @admin
end