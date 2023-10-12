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

  it 'destroy unused Status' do
    status = FactoryBot.create(:status)
    expect(Status.count).to be(1)

    delete :destroy, params: { id: status.id }

    expect_message(:notice, I18n.t('messages.status_successfully_destroyed'))
    expect(Status.count).to be(0)
  end

  it 'try to destroy a Status used by a Candidate' do
    status = FactoryBot.create(:status)
    candidate = FactoryBot.create(:candidate)
    expect(candidate.status_id).to be(status.id)
    expect(Status.count).to be(1)

    delete :destroy, params: { id: status.id }
    expect_message(:alert, I18n.t('messages.status_not_destroyed'))
    expect(Status.count).to be(1)
    expect(Candidate.all.first.status_id).to eq(status.id)
  end

  private

  def expect_message(id, message)
    %i[alert notice].each do |my_id|
      expect(flash[my_id]).to be_nil unless my_id == id
    end
    expect(flash[id]).to eq(message) unless id.nil?
  end
end
