# frozen_string_literal: true

feature 'New Candidate', :devise do
  before(:each) do
  end

  context 'test spanish' do
    let(:locale) { 'es' }

    it_behaves_like 'new_candidate_spec'
  end

  context 'test english' do
    let(:locale) { 'en' }

    it_behaves_like 'new_candidate_spec'
  end
end
