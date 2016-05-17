
describe AdminsController do

  it "should NOT have a current_candidate" do
    expect(subject.current_candidate).to eq(nil)
  end

  it "should fail authentication" do
    login_candidate
    get :index
    expect(@candidates).to eq(nil)
  end

  it "should pass authentication and set @admins" do
    login_admin
    get :index
    expect(subject.admins.size).to eq(1)
  end

end