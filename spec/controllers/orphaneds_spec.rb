# frozen_string_literal: true

describe CandidatesController do
  before(:each) do
    @candidate = FactoryBot.create(:candidate)
    login_admin
  end

  describe 'behaves like' do
    before(:each) do
    end

    describe 'orphaned_scanned_image' do
      it_behaves_like 'orphaned_scanned_image'
    end
  end
end
