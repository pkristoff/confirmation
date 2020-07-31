# frozen_string_literal: true

describe Dev::CandidatesController do
  include Warden::Test::Helpers
  before(:each) do
    @candidate = login_candidate
  end

  describe 'behaves like' do
    before(:each) do
    end

    describe 'orphaned_scanned_image' do
      it_behaves_like 'orphaned_scanned_image'
    end
  end
end
