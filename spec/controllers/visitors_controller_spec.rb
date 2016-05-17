
describe VisitorsController do

  it "should NOT have a current_candidate" do
    expect(subject.current_candidate).to eq(nil)
  end

  it "renders the index template" do
    get :index
    expect(response).to render_template("index")
  end

  describe 'Login as candidate' do

    before(:each) do
      @candidate = login_candidate
    end

    it "should have a current_candidate" do
      expect(subject.current_candidate).to eq(@candidate)
    end

    it "redirects to candidates show" do
      get :index
      expect(response).to redirect_to("http://test.host/show/#{@candidate.id}")
    end

  end

  describe 'Login as admin' do

    before(:each) do
      @admin = login_admin
    end

    it "should have a current_admin" do
      expect(subject.current_admin).to eq(@admin)
    end

    it "redirects to candidates show" do
      get :index
      expect(response).to redirect_to("http://test.host/admins/#{@admin.id}")
    end

  end
end