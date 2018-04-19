# frozen_string_literal: true

describe Admin do
  before(:each) { @admin = AppFactory.create_admin(email: 'candidate@example.com') }

  subject { @admin }

  it '#email returns a string' do
    expect(@admin.email).to match 'candidate@example.com'
  end
end
