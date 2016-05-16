
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

  xdescribe 'edit' do
    skip 'cannot get working in namespace - remove x'

    it 'show should not rediect if admin' do
      admin = login_admin
      get :edit, id: admin.id
      puts response.body
      expect(response).to render_template('edit')
      expect(controller.candidate).to eq(admin)
      expect(@request.fullpath).to eq("/candidates/#{admin.id}")
    end

  end

end


#
#
# def login_candidate
#   @request.env["devise.mapping"] = Devise.mappings[:candidate]
#   candidate = FactoryGirl.create(:candidate)
#   sign_in candidate
# end
# def login_admin
#   @request.env["devise.mapping"] = Devise.mappings[:admin]
#   @admin = FactoryGirl.create(:admin)
#   sign_in @admin
#   @admin
# end