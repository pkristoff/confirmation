# frozen_string_literal: true

describe 'New Candidate', :devise do
  context 'with english' do
    let(:locale) { 'en' }

    it_behaves_like 'new_candidate_spec'
  end

  context 'with spanish' do
    let(:locale) { 'es' }

    it_behaves_like 'new_candidate_spec'
  end
end
