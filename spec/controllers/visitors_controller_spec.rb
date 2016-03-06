
describe VisitorsController do

  it "should NOT have a current_user" do
    expect(subject.current_user).to eq(nil)
  end

  it "renders the index template" do
    get :index
    expect(response).to render_template("index")
  end

  it "should have a current_user" do
    login_user
    expect(subject.current_user).to eq(@user)
  end

  it "renders the index template" do
    login_user
    get :index
    expect(response).to redirect_to("http://test.host/users#index")
  end

  it "should have a current_admin" do
    login_admin
    expect(subject.current_admin).to eq(@admin)
  end

  it "renders the index template" do
    login_admin
    get :index
    expect(response).to redirect_to("http://test.host/admins#index")
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
end