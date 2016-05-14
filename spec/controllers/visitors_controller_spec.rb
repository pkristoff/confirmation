
describe VisitorsController do

  it "should NOT have a current_candidate" do
    expect(subject.current_candidate).to eq(nil)
  end

  it "renders the index template" do
    get :index
    expect(response).to render_template("index")
  end

  it "should have a current_candidate" do
    login_candidate
    expect(subject.current_candidate).to eq(@candidate)
  end

  it "renders the index template" do
    login_candidate
    get :index
    expect(response).to redirect_to("http://test.host/candidates#index")
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


  # def login_candidate
  #     @request.env["devise.mapping"] = Devise.mappings[:candidate]
  #     @candidate = FactoryGirl.create(:candidate)
  #     sign_in @candidate
  # end
  # def login_admin
  #     @request.env["devise.mapping"] = Devise.mappings[:admin]
  #     @admin = FactoryGirl.create(:admin)
  #     sign_in @admin
  # end
end