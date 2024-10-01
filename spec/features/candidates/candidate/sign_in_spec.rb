# frozen_string_literal: true

describe 'Baptismal Certificate admin', :devise do
  context 'with english' do
    let(:locale) { 'en' }

    it_behaves_like 'when locale_changed'
  end

  context 'with spanish' do
    let(:locale) { 'es' }

    it_behaves_like 'when locale_changed'
  end
  # dev
end
