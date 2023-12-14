# frozen_string_literal: true

describe CandidatesController do
  before do
    AppFactory.generate_default_status
    @candidate = FactoryBot.create(:candidate)
    login_admin
  end

  describe 'behaves like' do
    describe 'orphaned_scanned_image' do
      it_behaves_like 'orphaned_scanned_image'
    end
  end
end
