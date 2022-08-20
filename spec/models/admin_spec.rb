# frozen_string_literal: true

describe Admin do
  subject { @admin }

  before { @admin = AppFactory.create_admin(email: 'candidate@example.com') }

  it '#email returns a string' do
    expect(@admin.email).to match 'candidate@example.com'
  end
end
