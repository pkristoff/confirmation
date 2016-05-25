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

  it 'creates confirmation_events' do
    expect(ConfirmationEvent.all.size).to eq(1)
    confirmation_event = ConfirmationEvent.find_by(name: 'Parent Information Meeting')
    expect(confirmation_event.name).to eq('Parent Information Meeting')
    expect(confirmation_event.due_date).to eq(Date.today)
  end

end
