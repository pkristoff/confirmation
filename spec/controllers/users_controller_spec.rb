describe UsersController do

  it "should NOT have a current_user" do
    expect(subject.current_user).to eq(nil)
  end

  describe "index" do

    it "should fail authentication" do
      login_admin
      get :index
      expect(@users).to eq(nil)
    end

    it "should pass authentication and set @users" do
      login_user
      get :index
      expect(subject.users.size).to eq(1)
      expect(response).to render_template("index")
    end

  end

  describe "index" do

    it "show should not rediect if admin" do
      user = FactoryGirl.create(:user)
      @request.env['HTTP_REFERER'] = 'XXX'
      login_admin
      get :show, {:id => user.id}
      expect(response).to render_template("show")
      expect(controller.user).to eq(user)
      expect(@request.fullpath).to eq("/users/#{user.id}")
    end

    it "show should not rediect if user" do
      user = login_user
      @request.env['HTTP_REFERER'] = 'XXX'
      get :show, {:id => user.id}
      expect(response).to render_template("show")
      expect(controller.user).to eq(user)
      expect(@request.fullpath).to eq("/users/#{user.id}")
    end

    it "show should rediect if another use" do
      other = FactoryGirl.create(:user, {name: 'other', email: 'abc@xxx.com'})
      login_user
      @request.env['HTTP_REFERER'] = 'XXX'
      get :show, {:id => other.id}
      expect(response).not_to render_template("show")
      expect(response).to redirect_to('XXX')
    end

  end

end


def login_user
  @request.env["devise.mapping"] = Devise.mappings[:user]
  @user = FactoryGirl.create(:user)
  sign_in @user
  @user
end

def login_admin
  @request.env["devise.mapping"] = Devise.mappings[:admin]
  @admin = FactoryGirl.create(:admin)
  sign_in @admin
end