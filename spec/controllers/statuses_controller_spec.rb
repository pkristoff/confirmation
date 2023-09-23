# frozen_string_literal: true

describe StatusesController do
  before do
    FactoryBot.create(:visitor)
    @admin = login_admin
  end

  it 'NOT have a current_candidate' do
    expect(subject.current_candidate).to be_nil
  end

  it 'show list of statuses' do
    get :index
  end
end
