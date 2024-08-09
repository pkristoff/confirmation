# frozen_string_literal: true

describe Admin do
  subject { @admin }

  before { @admin = AppFactory.create_admin(email: 'candidate@example.com') }

  it '#email returns a string' do
    expect(@admin.email).to match 'candidate@example.com'
  end

  it 'table_filter default returns "".to_json' do
    expect(@admin.table_filter).to match ''.to_json
  end

  it 'table_filter returns "".to_json' do
    @admin.table_filter = Admin.initial_sorting_settings.to_json
    expect(@admin.table_filter).to match Admin.initial_sorting_settings.to_json
  end
end
