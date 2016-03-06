describe Admin do

  before(:each) { @admin = Admin.new(email: 'user@example.com') }

  subject { @admin }

  it "#email returns a string" do
    expect(@admin.email).to match 'user@example.com'
  end

end
