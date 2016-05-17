describe CreateAdminsService do

  before(:each) {
    @admin = CreateAdminsService.new.call
  }

  subject { @admin }

  it '#email returns a string' do
    expect(@admin.email).to match 'confirmation@kristoffs.com'
    expect(@admin.name).to match 'Admin'
    expect(@admin.password).to match '12345678'
  end

end
